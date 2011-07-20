class BroadcastTransaction < ActiveRecord::Base

  validates_presence_of :txid, :rawtransaction

  def self.rebroadcast
    BroadcastTransaction.all.each do |btx|
      if btx.broadcasted_at < Time.now - 30.minutes
        rtx = BITCOIN.getrawtransaction btx.txid
        if rtx["parent_blocks"].any?
          btx.destroy
        else
          BITCOIN.importtransaction btx.rawtransaction
          btx.broadcasted_at = Time.now
          btx.tries += 1
          btx.save
          if btx.tries > 100
            btx.destroy
          end
        end
      end
    end
  end

end
