module ApplicationHelper

  def display_amount amount

    unit = current_user.setting("units")
    amount = amount.to_f * User::UNITS[unit]
    
    case current_user.setting(:language)
    when "de"
      separator = ','; delimiter = '.'
    else
      separator = '.'; delimiter = ','
    end
    precision = (unit == 'satoshi') ? 0 : 2
    number_to_currency(amount, :precision => precision,
                       :unit => "", :locale => current_user.setting(:locale),
                       :separator => separator, :delimiter => delimiter)
    
  end

  def display_address address
    if address.label && address.label != ""
      name = address.label
    else
      name = address.address
    end
    
    link_to name, address_path(address), :title => address.address
  rescue
    p $!
  end

  def display_time time
    Time.at(time).strftime("%Y-%m-%d %H:%M:%S")
  end

  def display_txid txid
    link_to txid.truncate(20), transaction_path(txid), :title => txid rescue "-"
  end

end
