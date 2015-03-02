# https://gist.github.com/jacobian/612395
# http://www.devopsnotes.com/2012/02/how-to-write-good-chef-cookbook.html
define :initscripts, :action => :create, :message => 'test' do
 log params[:message] do
   level :info
 end
 log params[:name] do
   level :info
 end
end    
