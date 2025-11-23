/**
1. Mostrame todos los productos con su línea de producto y precio

2. Quiero ver cuántos productos hay por cada línea de producto

3. Decime cuáles son los productos que tienen menos stock que el promedio general

4. Listame los productos que nunca se vendieron en ningún pedido

5. Mostrame los productos más vendidos (ordenados por cantidad total pedida)
*/

-- 1
select p.productCode,p.productName,p.buyPrice,pl.textDescription from products as p inner join productlines as pl on p.productLine=pl.productLine;

--2 
SELECT productLine, COUNT(*) AS cantidadProductos FROM products GROUP BY productLine;

--3 
set @promedio = (select avg(quantityInStock) from products);
select productCode,productName,quantityInStock from products where quantityInStock < @promedio;

--4 
select products.productcode,productname,orderNumber from products left join orderdetails on products.productCode=orderdetails.productcode where orderNumber is null;
