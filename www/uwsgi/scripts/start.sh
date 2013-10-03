# 
if [ -d ~/ve/ah ]
  then
    source ~/ve/ah/bin/activate
fi

# Start uWSGI Emperor
# https://uwsgi-docs.readthedocs.org/en/latest/Emperor.html
uwsgi --emperor ~/archiveshub/www/uwsgi/apps --vassals-include ~/archiveshub/www/uwsgi/vassals.ini --emperor-pidfile ~/archiveshub/www/uwsgi/archiveshub.pid --daemonize ~/archiveshub/www/uwsgi/archiveshub.log --emperor-stats-server 127.0.0.1:8888
