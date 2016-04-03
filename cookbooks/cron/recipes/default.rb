cron "make file" do
  user "root"
  command "touch /tmp/hogeee.txt"
  hour "17"
  minute "51"
end
