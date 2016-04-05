FROM centos:centos6

ENV CHEFHOME /Users/hidetoshi/Vagrant/Base-OS-Cent/
ADD chef-repo /root/chef-repo
 
RUN RUN curl -L http://www.opscode.com/chef/install.sh | bash
RUN cd ${CHEFHOME} && chef-solo -c ${CHEFHOME}/solo.rb -j ${CHEFHOME}/nodes/docker.json
 
