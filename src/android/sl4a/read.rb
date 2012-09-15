require "android";

droid = Android.new

if(droid.bluetoothActiveConnections())
  droid.bluetoothConnect()
  puts "connected successfully!"

  while(true)
    puts droid.bluetoothRead(1)
  end
else
  puts "no connections!"
end

puts "-done-"