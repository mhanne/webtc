module ApplicationHelper

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
