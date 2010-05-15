# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def logged_in?
    current_user
  end
  def merged_name(first, last)
    if !last.nil?
      return first + '.' + last[0,2]
    else
      return first
    end
  end

  def show_photo(photo)
    if !photo.nil?
      return image_tag(photo.public_filename(:thumb))
    else
      return image_tag('no-thumb-photo.png')
    end
  end

  def show_tiny_photo(photo)
    if !photo.nil?
      return image_tag(photo.public_filename(:tiny))
    else
      return image_tag('no-tiny-photo.png')
    end
  end

  def show_correctness(correct)
    if correct
      image_tag('ok.png')
    else
      image_tag('ng.png')
    end
  end    

  def show_percent_word(all, some)
    if all == some
      return 'Бүгд зөв<br />' + image_tag('percent-all.png')
    elsif (all - some) < some
      return 'Ихэнх нь зөв<br />' + image_tag('percent-almost.png')
    elsif (all - some) == some
      return 'Хагас нь зөв<br />' + image_tag('percent-half.png')
    elsif some != 0
      return 'Ихэнх нь буруу<br />' + image_tag('percent-some.png')
    else
      return 'Бүгд буруу<br />' + image_tag('percent-none.png')
    end
  end

  def contest_link(contest)
    link_to(contest.name,
            :controller=>'contests',
            :action=>'show',
            :id=>contest.id)
  end

  def problem_link(problem)
    link_to(problem.name,
            :controller=>'problems',
            :action=>'show',
            :id=>problem.id)
  end

  def language_link(l)
    link_to(l.name,
            :controller=>'languages',
            :action=>'show',
            :id=>l.id)
  end

  def shorten(str, len)
    if str.length > len
      return str[0,len] + '...'
    end
    return str
  end

  def bytize(bytes)
    if bytes < 1024
      return bytes.to_s + 'b'
    elsif bytes < 1024*1024
      return (bytes/1024).to_s + 'Kb'
    else
      return (bytes/(1024*1024)).to_s + 'Mb'
    end
  end

  def test_type(test)
    if test.hidden
      "Жинхэнэ"
    else
      "Туршилт"
    end
  end

  def true_false(bool)
    if bool
      'Тийм'
    else
      'Үгүй'
    end
  end

  def sec2milisec(sec)
      "%0.3f" % (sec.to_f/1000)
  end

  def translate_message(msg)
    if msg.strip.eql?('OK')
      'Хэвийн'
    elsif msg.strip.eql?('Time Limit Exceeded')
      'Хугацаа хэтрэв'
    elsif msg.strip.eql?('Memory Limit Exceeded')
      'Санах ой хэтрэв'
    elsif msg.strip.eql?('Output Limit Exceeded')
      'Гаралт хэтрэв'
    elsif msg.strip.eql?('Invalid Function')
      'Буруу үйлдэл'
    elsif msg.strip[0,19].eql?('Command exited with')
      "Алдаа буцаалаа"
    else
      msg
    end
  end

  def test_purpose(result)
    if result.test.hidden
      image_tag('test-hidden.png')
    else
      link_to(image_tag('test-open.png'),
              :controller=>'results', :action=>'show',
              :id => result)
    end
  end

  def user_info_small(id)
    user = User.find(id)
    photo = user.photo
    if !photo.nil?
      return (link_to(image_tag(photo.public_filename(:tiny), :alt=>'photo') +
                      '<div class=small>%s</div>' % user.login,
                      :controller=>'account',
                      :action=>'show', :id=>id))
    else
      return (link_to(image_tag('no-tiny-photo.png', :alt=>'no photo') +
                      '<div class=small>%s</div>' % user.login,
                      :controller=>'account',
                      :action=>'show', :id=>id))
    end

  end

  def  standing(num)
    if num > 3
      return num
    end
    if num == 1
      image_tag('cup-gold.png', :title=> 'Алт')
    elsif num == 2
      image_tag('cup-silver.png', :title=> 'Мөнгө')
    elsif num == 3
      image_tag('cup-bronze.png', :title=> 'Хүрэл')
    end
  end

  def medal_list(standings)
    list =''
    medal_color = 1
    standings.sort{|a,b| a[1]<=>b[1]}.each { |c, s|
      if s < 4
        if medal_color != s
          medal_color = s
          list += '<br />'
        end
        list += link_to(standing(s),c)
      end
    }
    return list
  end

  def hugatsaa_zawsar(from_time, to_time = Time.now, include_seconds = true)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round
    distance_in_seconds = ((to_time - from_time).abs).round

    case distance_in_minutes
    when 0..1
      return (distance_in_minutes == 0) ? '1 миунтаас бага' : '1 минут' unless include_seconds
      case distance_in_seconds
      when 0..4   then '5 секунд'
      when 5..9   then '10 секунд'
      when 10..19 then '20 секунд'
      when 20..39 then 'хагас минут'
      when 40..59 then '1 минут'
      else             '1 минут'
      end

    when 2..44           then "#{distance_in_minutes} минут"
    when 45..89          then '1 цаг'
    when 90..1439        then "#{(distance_in_minutes.to_f / 60.0).round} цаг"
    when 1440..2879      then '1 өдөр'
    when 2880..43199     then "#{(distance_in_minutes / 1440).round} өдөр"
    when 43200..86399    then '1 сар'
    when 86400..525959   then "#{(distance_in_minutes / 43200).round} сар"
    when 525960..1051919 then '1 жил'
    else                      "#{(distance_in_minutes / 525960).round} жил"
    end
  end

end
