def x = eval("<%= params[:xor].to_s.bytes %>").map(&:chr).join.to_i
def no(*) = exit 0.succ#ess
e=DATA.read.split.map{it.to_i.send(:^,x)}
i=gets&.chomp
e.zip(i.bytes).map{it.reduce(:==)}.reject{it}.each{no}
no(DATA) if e.size != i.size
