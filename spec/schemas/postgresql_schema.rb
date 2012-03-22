sql = <<-SQL
DROP TABLE IF EXISTS ShoppingCarts;
DROP TABLE IF EXISTS Clients;
DROP TABLE IF EXISTS Articles;

CREATE TABLE Articles(
  id INTEGER NOT NULL
, name VARCHAR(255) NOT NULL
, price FLOAT NOT NULL
);

ALTER TABLE Articles
  ADD CONSTRAINT
    article_pk_id
    PRIMARY KEY(id);

CREATE TABLE ShoppingCarts
(
  a_id INTEGER NOT NULL
, c_id INTEGER NOT NULL
, number INTEGER
);

ALTER TABLE ShoppingCarts
  ADD CONSTRAINT
    shoppingcart_pk_a_id_c_id
      PRIMARY KEY(a_id, c_id);

ALTER TABLE ShoppingCarts
  ADD CONSTRAINT
    shoppingcart_fk_a_id
      FOREIGN KEY(a_id) REFERENCES Articles(id)
                             ON DELETE RESTRICT;

CREATE TABLE Clients
(
  id INTEGER NOT NULL
, name VARCHAR(100)
);

ALTER TABLE Clients
  ADD CONSTRAINT client_pk_id
    PRIMARY KEY(id);

ALTER TABLE ShoppingCarts
  ADD CONSTRAINT shoppingcart_fk_c_id
    FOREIGN KEY(c_id) REFERENCES Clients(id)
                         ON DELETE RESTRICT;

COPY Articles(id, name, price)
    FROM '#{Dir.pwd + "/spec/schemas/values/articles.csv"}'
    WITH CSV;

COPY Clients(id, name)
    FROM '#{Dir.pwd + "/spec/schemas/values/clients.csv"}'
    WITH CSV;

COPY ShoppingCarts(a_id, c_id, number)
    FROM '#{Dir.pwd + "/spec/schemas/values/shoppingcarts.csv"}'
    WITH CSV;

VACUUM;
SQL

print " - Creating schema and inserting values ... "

sql.split(/;/).select(&:present?).each do |sql_statement|
  ActiveRecord::Base.connection.execute sql_statement
end

puts "done"
