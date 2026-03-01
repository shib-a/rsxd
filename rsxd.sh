export PGDATA=$HOME/qje95
export PGENCODING=ISO_8859_5
export PGLOCALE=ru_RU.$PGENCODING
export PGWAL=$HOME/jjt13

mkdir $PGDATA
mkdir $PGWAL

initdb -D $PGDATA -E $PGENCODING --locale=$PGLOCALE --waldir=$PGWAL --auth-local=peer --auth-host=scram-sha-256

echo "port = 9091" >> $PGDATA/postgresql.conf
echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf

echo "max_connections = 200" >> $PGDATA/postgresql.conf
echo "shared_buffers = 4GB" >> $PGDATA/postgresql.conf
echo "temp_buffers = 8MB" >> $PGDATA/postgresql.conf
echo "work_mem = 4MB" >> $PGDATA/postgresql.conf
echo "checkpoint_timeout = 10min" >> $PGDATA/postgresql.conf
echo "effective_cache_size = 12GB" >> $PGDATA/postgresql.conf
echo "fsync = on" >> $PGDATA/postgresql.conf
echo "commit_delay = 0" >> $PGDATA/postgresql.conf

echo "log_destination = 'csvlog'" >> $PGDATA/postgresql.conf
echo "logging_collector = on" >> $PGDATA/postgresql.conf
echo "log_directory = 'log'" >> $PGDATA/postgresql.conf
echo "log_filename = 'postgresql-%Y-%m-%d.csv'" >> $PGDATA/postgresql.conf
echo "log_min_messages = notice" >> $PGDATA/postgresql.conf
echo "log_connections = on" >> $PGDATA/postgresql.conf
echo "log_disconnections = on" >> $PGDATA/postgresql.conf


echo "local all all peer" > $PGDATA/pg_hba.conf
echo "host all all 0.0.0.0/0 scram-sha-256" >> $PGDATA/pg_hba.conf
echo "host all all ::/0 scram-sha-256" >> $PGDATA/pg_hba.conf

pg_ctl start -D $PGDATA -l $PGDATA/server.log
