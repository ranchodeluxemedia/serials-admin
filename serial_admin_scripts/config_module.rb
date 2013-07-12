module ConfigModule
  def get_vars(conf_file)
    line_sub = Regexp.new(/\s+|"|\[|\]/)
    temp = []
    vars = {}
    unless File.exists?(conf_file) then
      raise "Config file does not exist."
    end

    File.open(conf_file).each do |line|
      if line.match(/^#/) # ignore comments
        next
      elsif line.match(/^$/) # ignore blank lines
        next
      else
        temp[0], temp[1]=line.split('=')
        temp.collect! do |val|
          val.gsub(line_sub, "")
        end
        vars[temp[0]]=temp[1]
      end
    end
    return vars
  end
end
        
