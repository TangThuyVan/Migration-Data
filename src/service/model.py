from sqlalchemy import create_engine


class ConnPostgre:
    def __init__(self, host, user, password, database):
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.conn = self.create_connection()

    def create_connection(self):
        conn = create_engine("postgresql://"+ self.user + ":" + self.password + "@" + self.host + "/" + self.database)
        return conn

    def sql_insert(self, table_name, data_frame):
        data_frame.to_sql(table_name, self.conn, if_exists='append', index=False)
        return True
    def sql_change(self, table_name, data_frame):
        data_frame.to_sql(table_name, self.conn, if_exists='replace', index=False)
        return True