module ApplicationHelper

  include ActionView::Helpers::NumberHelper

  def display_amount amount
    unit = current_user.setting("units") rescue User::DEFAULT_SETTINGS[:units]
    amount = (amount || 0).to_f / User::UNITS[unit]
    language = current_user.setting(:language) rescue User::DEFAULT_SETTINGS[:language]
    case language
    when "de"
      separator = ','; delimiter = '.'
    else
      separator = '.'; delimiter = ','
    end
    precision = case unit
                  when 'satoshi' then 0
                  when 'uBTC' then 2
                  when 'mBTC' then 5
                  when 'BTC' then 8
                  end
    number_to_currency(amount.to_f, :precision => precision,
                       :unit => "", :locale => language,
                       :separator => separator, :delimiter => delimiter)
  end

  def display_address address
    if address.label && address.label != ""
      name = address.label
    else
      name = address.address
    end
    link_to name, address_path(address.address), :title => address.address
  rescue
    p $!
  end

  def display_time time
    Time.at(time).strftime("%Y-%m-%d %H:%M:%S")
  end

  def display_txid txid
    link_to txid.truncate(20), transaction_path(txid), :title => txid rescue "-"
  end

  def amount_in_words amount
    s = amount.to_s.split('.')
    res = Linguistics::EN.numwords(s[0])
    res << " point "  if s[1]
    res << s[1].split('').map {|n| Linguistics::EN.numwords(n)}.join(" ")  if s[1]
    res
  end

end
