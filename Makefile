up:
	docker compose up -d --build --remove-orphans

down:
	docker compose down

down-clean:
	docker compose down -v

minio-ui:
	open http://localhost:9001

pg-replica:
	docker-compose exec postgres-replica env PGOPTIONS="--search_path=school" bash -c 'psql -U postgres postgres'

pg:
	docker-compose exec postgres env PGOPTIONS="--search_path=school" bash -c 'psql -U postgres postgres'

pg-sink-postgres:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8084/connectors/ -d '@./connectors/sink-postgres-school.json'

pg-sink-db2:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8084/connectors/ -d '@./connectors/sink-postgres-inventory.json'

pg-src:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8085/connectors/ -d '@./connectors/postgres.json'

db2-src:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8085/connectors/ -d '@./connectors/db2.json'

s3-sink:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8084/connectors/ -d '@./connectors/sink-minio.json'

init-connectors: pg-src pg-sink-postgres s3-sink db2-src pg-sink-db2

status-connector-sink:
	curl -i -X GET -H "Accept:application/json" -H "Content-Type:application/json" localhost:8084/connectors/?expand=status

status-connector-source:
	curl -i -X GET -H "Accept:application/json" -H "Content-Type:application/json" localhost:8085/connectors/?expand=status

list-connectors: status-connector-source status-connector-sink

restart-pg-src:
	curl -i -X POST localhost:8085/connectors/postgres-source-connector/restart

restart-db2-src:
	curl -i -X POST localhost:8085/connectors/db2-source-connector/restart

restart-src-connectors: restart-pg-src restart-db2-src

restart-pg-sink-db2:
	curl -i -X POST localhost:8084/connectors/postgres-JDBC-sink-connector-inventory/restart

restart-pg-sink-pg:
	curl -i -X POST localhost:8084/connectors/postgres-JDBC-sink-connector-school/restart

restart-s3-sink:
	curl -i -X POST localhost:8084/connectors/minio-sink-connector/restart

restart-sink-connectors: restart-pg-sink-db2 restart-pg-sink-pg restart-s3-sink

restart-connectors: restart-src-connectors restart-sink-connectors

delete-db2-src:
	curl -i -X DELETE localhost:8085/connectors/db2-source-connector/

delete-pg-src:
	curl -i -X DELETE localhost:8085/connectors/postgres-source-connector/

delete-src-connectors: delete-db2-src delete-pg-src

delete-pg-sink-db2:
	curl -i -X DELETE localhost:8084/connectors/postgres-JDBC-sink-connector-inventory/

delete-pg-sink-pg:
	curl -i -X DELETE localhost:8084/connectors/postgres-JDBC-sink-connector-school/

delete-s3-sink:
	curl -i -X DELETE localhost:8084/connectors/minio-sink-connector/

delete-sink-connectors: delete-pg-sink-db2 delete-pg-sink-pg delete-s3-sink

delete-connectors: delete-src-connectors delete-sink-connectors

monitor:
	docker-compose exec kafka /kafka/bin/kafka-console-consumer.sh \
		--bootstrap-server kafka:9092 \
		--from-beginning \
		--property print.key=true \
		--whitelist 'postgres.school.student|postgres.DB2INST1.CUSTOMERS|postgres.DB2INST1.ORDERS|postgres.DB2INST1.PRODUCTS|postgres.DB2INST1.PRODUCTS_ON_HAND'

list-topics:
	docker-compose exec kafka /kafka/bin/kafka-topics.sh \
		--bootstrap-server kafka:9092 \
		--list

monitor-connector-sink:
	docker logs -f kafka-connect-sink

monitor-connector-source:
	docker logs -f kafka-connect-source

monitor-connector: monitor-connector-sink monitor-connector-source

restart-datagen:
	docker compose restart datagen