export PGDATA=$HOME/qje95
export PGENCODING=ISO_8859_5
export PGLOCALE=ru_RU.ISO8859-5
export PGWAL=$HOME/jjt13

export PGTABLESPACE1=$HOME/ifu88
export PGTABLESPACE2=$HOME/bqz31

mkdir $PGDATA
mkdir $PGWAL

initdb -D $PGDATA -E $PGENCODING --locale=$PGLOCALE --waldir=$PGWAL --auth-local=peer --auth-host=scram-sha-256

echo "port = 9091" >> $PGDATA/postgresql.conf
echo "listen_addresses = '*'" >> $PGDATA/postgresql.conf

echo "max_connections = 200" >> $PGDATA/postgresql.conf
echo "shared_buffers = 2GB" >> $PGDATA/postgresql.conf
echo "temp_buffers = 8MB" >> $PGDATA/postgresql.conf
echo "work_mem = 4MB" >> $PGDATA/postgresql.conf
echo "checkpoint_timeout = 10min" >> $PGDATA/postgresql.conf
echo "effective_cache_size = 4GB" >> $PGDATA/postgresql.conf
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

#task3

mkdir $PGTABLESPACE1
mkdir $PGTABLESPACE2

chmod 700 $PGTABLESPACE1
chmod 700 $PGTABLESPACE2

psql -p 9091 -d postgres -c "CREATE TABLESPACE ts1 LOCATION '$PGTABLESPACE1';"
psql -p 9091 -d postgres -c "CREATE TABLESPACE ts2 LOCATION '$PGTABLESPACE2';"

psql -p 9091 -d postgres -c "CREATE DATABASE wetwhitedisk TEMPLATE template1;"
psql -p 9091 -d postgres -c "\l"

psql -p 9091 -d postgres -c "CREATE USER psz WITH PASSWORD 'psz123!';"
psql -p 9091 -d postgres -c "GRANT ALL PRIVILEGES ON DATABASE wetwhitedisk TO psz;"

PGPASSWORD=psz123! psql -h 127.0.0.1 -p 9091 -d wetwhitedisk -U psz <<'SQL'
SET temp_tablespaces = ts1;
CREATE TEMPORARY TABLE dopsa (
isu_id text PRIMARY KEY CHECK (isu_id ~ '^s[0-9]{6}$'),
subject text NOT NULL,
score integer NOT NULL CHECK (score >= 0 AND score <= 100),
fio text NOT NULL
);

INSERT INTO dopsa VALUES
('s409858', 'СИИ', 38, 'Чусовлянов Максим Сергеевич'),
('s409091', 'ИС', 30, 'Мартышов Данила Викторович'),
('s372411', 'ОС', 32, 'Солодовников Данила Дмитриевич'),
('s368748', 'ВЕБ', 35, 'Садовой Григорий Владимирович');

SET temp_tablespaces = ts2;
CREATE TEMPORARY TABLE comsa (
isu_id text PRIMARY KEY CHECK (isu_id ~ '^s[0-9]{6}$'),
subject text NOT NULL,
fio text NOT NULL,
survive_probability real NOT NULL CHECK (survive_probability >= 0 AND survive_probability <= 1)
);

INSERT INTO comsa VALUES
('s409091', 'Физкультура', 'Мартышов Данила Викторович', 0.1),
('s412981', 'АK', 'Кривошеев Кирилл Александрович', 0.2),
('s409829', 'Матан', 'Черемисова Мария Александровна', 0.05),
('s413786', 'Английский', 'Мачин Данила Алексеевич', 0.0);

SELECT c.relname,
       COALESCE(t.spcname,'pg_default') AS tablespace
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
LEFT JOIN pg_tablespace t ON t.oid = c.reltablespace
WHERE n.nspname LIKE 'pg_temp_%'
ORDER BY c.relname;
SQL

pg_ctl stop -D $PGDATA -m fast