import random
from threading import Thread
from time import sleep

import ibm_db
import psycopg2
from faker import Faker

fake = Faker()


def gen_postgres_data(num_records: int) -> None:
    conn = psycopg2.connect(
        "dbname='postgres' user='postgres' host='postgres' password='postgres'"
    )

    for _ in range(num_records):
        id = random.randint(1, num_records)
        curr = conn.cursor()
        name = fake.user_name()
        print(f"Inserting id: {id} name: {name}")
        try:
            curr.execute(
                "INSERT INTO school.student (id, name) VALUES (%s, %s)",
                (id, name),
            )
        except Exception as e:
            print(f"Problem in insert {e}")
        conn.commit()

        sleep(0.5)
        # update 10 % of the time
        if random.randint(1, 100) >= 90:
            curr.execute(
                "UPDATE school.student SET name = %s WHERE id = %s",
                (name, id),
            )
        conn.commit()

        sleep(0.5)
        # delete 5 % of the time
        if random.randint(1, 100) >= 95:
            try:
                curr.execute("DELETE FROM school.student WHERE id = %s", (id,))
            except Exception as e:
                print(f"Problem in delete {e}")

        conn.commit()
        curr.close()

    return


def test_db2_connection():
    try:
        db2_conn_str = "DATABASE=TESTDB;HOSTNAME=db2server;PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD==Password!;"
        conn = ibm_db.connect(db2_conn_str, "", "")
        print("Connection to db2 successful!")
        ibm_db.close(conn)
        return True
    except Exception as e:
        print(f"Connection to db2 failed: {e}")
        return False


def gen_db2_data(num_records: int) -> None:
    while not test_db2_connection():
        print("Retrying connection in 5 seconds...")
        sleep(5)

    fake = Faker()

    db2_conn_str = "DATABASE=TESTDB;HOSTNAME=db2server;PORT=50000;PROTOCOL=TCPIP;UID=db2inst1;PWD==Password!;"
    conn = ibm_db.connect(db2_conn_str, "", "")

    for _ in range(num_records):
        id = random.randint(1, num_records)

        first_name = fake.first_name()
        last_name = fake.last_name()
        email = fake.email()

        print(
            f"Inserting firstname: {first_name}, lastname: {last_name} email: {email}"
        )
        try:
            curr = ibm_db.prepare(
                conn,
                "INSERT INTO DB2INST1.CUSTOMERS(first_name,last_name,email) VALUES (? , ?, ?);",
            )
            ibm_db.bind_param(curr, 1, first_name)
            ibm_db.bind_param(curr, 2, last_name)
            ibm_db.bind_param(curr, 3, email)
            ibm_db.execute(curr)
        except Exception as e:
            print(f"Problem in insert {e}")

        sleep(0.5)
        if random.randint(1, 100) >= 90:
            first_name = fake.first_name()
            try:
                curr = ibm_db.prepare(
                    conn, "UPDATE DB2INST1.CUSTOMERS SET first_name = ? WHERE id = ?"
                )
                ibm_db.bind_param(curr, 1, first_name)
                ibm_db.bind_param(curr, 2, id)
                ibm_db.execute(curr)
            except Exception as e:
                print(f"Problem in update {e}")

        sleep(0.5)
        if random.randint(1, 100) >= 95:
            try:
                curr = ibm_db.prepare(
                    conn, "DELETE FROM DB2INST1.CUSTOMERS WHERE id = ?"
                )
                ibm_db.bind_param(curr, 1, id)
                ibm_db.execute(curr)
            except Exception as e:
                print(f"Problem in delete {e}")

    ibm_db.close(conn)

    return


if __name__ == "__main__":
    postgres_data_thread = Thread(target=gen_postgres_data, args=(1000,))
    postgres_data_thread.start()

    db2_data_thread = Thread(target=gen_db2_data, args=(1000,))
    db2_data_thread.start()

    postgres_data_thread.join()
    db2_data_thread.join()
