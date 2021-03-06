class Problem < ActiveRecord::Base
  LEVELS = [1, 2, 4, 8]
  PRICES = { 
    1 => 5, 
    2 => 10, 
    4 => 25, 
    8 => 50 }
  belongs_to :contest
  belongs_to :user

  has_many :solutions
  has_many :tests, :class_name => 'ProblemTest', 
           :order => 'hidden DESC, id ASC',
           :dependent => :destroy
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'
  has_many :users, :through => :solutions, :uniq => true

  validates_presence_of :name, :text
  validates_inclusion_of :level, :in => LEVELS

  named_scope :commented, :conditions => "comments_count > 0"
  named_scope :active, :conditions => ["active_from < ?", Time.now]

  before_save :copy_times

  after_save :notify_user
  
  def active?
    self.active_from && (self.active_from < Time.now)
  end

  def owned_by?(someone)
    self.user_id == someone.id
  end

  def correct_solutions
    solutions.correct
  end

  def best_solution
    self.solutions.correct.by_speed.first
  end

  def corrects_count
    Solution.count_by_sql(["SELECT count(id) FROM solutions where problem_id = ? AND correct = true", self.id])
  end

  def solutions_count
    solutions.count
  end

  def has_permission?(user)
    return false unless user
    return true if user.judge?
    return false unless self.contest.nil?
    return false if self.user_id != user.id
    return true
  end

  def available_to(user)
    return false unless user
    return true if user.judge?
    return true if self.user_id == user.id
    return false if self.contest.nil?
    return true if self.contest.started?
    return false
  end

  def test_addable?(user)
    return false unless user
    return true if user.judge?
    return true if self.user_id == user.id
    return false
  end

  define_index do
    indexes :name
    indexes :text
    indexes :source
    set_property :field_weights => { 
      :name => 10,
      :text => 6,
      :source => 3
    }
    set_property :delta => true
  end

  def check!
    unless self.tests.real.empty?
      self.solutions.each { |solution| solution.check! }
    end
  end

  def self.resum_counts!
    Problem.update_all("tried_count = 0, solved_count = 0")
    Problem.
      find(:all,
           :select => "problems.*, count(s.id) as tc, sum(s.correct) as sc",
           :joins => "left join solutions s on problems.id = s.problem_id",
           :group => "problems.id").each do |problem|
      Problem.update_counters(problem.id, 
                              :tried_count => problem.tc.to_i,
                              :solved_count => problem.sc.to_i)
    end
  end

  private 
  def copy_times
    if changes.has_key?('contest_id') && contest
      self.active_from = contest.start
      self.inactive_from = contest.end
    end
  end

  def notify_user
    if self.changes['contest_id']
      user.deliver_problem_selection!(contest, self)
    end
  end
end
