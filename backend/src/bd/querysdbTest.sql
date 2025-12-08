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

--5
select p.productcode,p.productname, sum(o.quantityordered) as Cantidad from products as p inner join orderdetails as o on p.productcode=o.productcode group by p.productcode,p.productName order by cantidad desc;
/**
👥 Clientes

“Mostrame todos los clientes junto con el nombre de su representante de ventas.”

“Quiero saber qué clientes nunca hicieron un pedido.”

“Dame el total de pagos que hizo cada cliente y ordenámelos del mayor al menor.”

“Listame los clientes que superaron su límite de crédito con sus pedidos.”

“Mostrame los clientes por país y cuántos hay en cada uno.”
*/

--1
 select c.customerName,c.contactFirstName,c.contactLastName,c.phone,concat(e.firstname,',',e.lastname) as `Nombre de vendedor` from customers as c inner join employees as e on c.salesRepEmployeeNumber=e.employeeNumber;

--2
select c.customerName,c.contactFirstName,c.contactLastName from customers as c left join orders as o on c.customerNumber=o.customerNumber where o.customerNumber is null;

--3
select c.customername, SUM(p.amount) as totalPago from customers as c inner join payments as p on c.customernumber=p.customernumber group by c.customername order by totalPago DESC;

--4

select c.customername,c.creditLimit, o.ordernumber as pedido,SUM(od.quantityordered*od.priceeach) as totalOrden from customers as c inner join orders as o on c.customernumber=o.customernumber inner join orderdetails as od on o.ordernumber=od.ordernumber group by c.customername,o.ordernumber having totalorden > c.creditLimit;

--5
select country,count(*) as Total from customers group by country order by total desc;


/**
🧑‍💼 Empleados

“Mostrame los empleados junto con la oficina donde trabajan.”

“Mostrame la jerarquía de empleados: quién reporta a quién.”

“Quiero saber cuántos empleados hay por cada oficina.”

“Listame los empleados que son representantes de ventas de al menos un cliente.”

“Mostrame los empleados que no tienen subordinados.”
*/
--1
select e.lastname,e.firstname,o.officecode from employees as e inner join offices as o on e.officecode=o.officecode;

--2
select e.lastname,e.firstname,e.employeenumber,m.lastname,m.firstname,m.employeenumber from employees as e inner join employees as m on e.employeenumber=m.reportsto where e.employeenumber is not null;

--3 
select e.officecode,o.city,count(*) from employees as e inner join offices as o
on e.officecode=o.officecode group by e.officecode,o.city;
-- 4
select concat(e.lastname,', ',e.firstname) as empleado, c.customername from employees as e inner join customers as c on e.employeenumber=salesrepemployeenumber;
-- 5
select e.lastname,e.firstname from employees as e left join employees as m on m.reportsto=e.employeenumber where m.reportsto is null;


/**
🏢 Oficinas

“Listame todas las oficinas y cuántos empleados tiene cada una.”

“Quiero ver las oficinas por país y cuántos empleados hay en cada país.”

“Mostrame solo las oficinas que tienen empleados que son representantes de ventas.”
*/


--1
select o.officecode, o.city, o.country, count(*) from offices as o inner join employees as e on o.officecode=e.officecode group by o.city,o.country;

--2
select o.country,count(*) as empleados from offices as o inner join employees as e on o.officecode=e.officecode group by o.country order by empleados desc;

--3
select distinct o.officecode, concat(o.country,', ',o.city) as Location, o.postalcode,o.territory from offices as o inner join employees as e on o.officecode=e.officecode inner join cus
tomers as c on e.employeenumber=c.salesrepemployeenumber;


/**
📦 Pedidos

“Mostrame todos los pedidos con el nombre del cliente.”

“Listame los pedidos que todavía no se enviaron.”

“Quiero ver los pedidos por mes, cuántos hubo y cuánto sumaron.”

“Mostrame el total vendido por pedido (sumando quantityOrdered × priceEach).”

“Decime cuáles pedidos tienen más de 3 líneas de detalle.”

“Listame los pedidos que incluyen productos de más de una línea de producto.”
*/
--1
select o.ordernumber,o.orderdate,o.status,c.customername from orders as o inner join customers as c on o.customernumber=c.customernumber;

--2
select ordernumber,orderdate,status from orders where status<>'Shipped';
--3
select year(o.orderdate) as Año, month(o.orderdate) as Mes,count(distinct o.ordernumber) as CantidadDePedidos, sum(od.quantityordered * od.priceeach) as TotalDelMes from orders as o inner join orderdetails as od on o.ordernumber=od.ordernumber group by Año,Mes;

--4
SELECT 
    o.orderNumber,
    o.orderDate,
    o.status,
    SUM(od.quantityOrdered * od.priceEach) AS TotalPedido
FROM orders AS o
INNER JOIN orderdetails AS od 
    ON o.orderNumber = od.orderNumber
WHERE o.status <> 'Cancelled'
GROUP BY o.orderNumber;


--5
select o.ordernumber,o.orderdate,count(od.ordernumber) as lineasdetalle from orders as o inner join orderdetails as od on o.ordernumber=od.ordernumber group by o.ordernumber,o.orderdate having lineasdetalle;

--6

select o.ordernumber,o.orderdate,count(distinct pl.productline) as cantidadLineasProducto from orders as o inner join orderdetails as od on o.ordernumber=od.ordernumber inner join products as p on od.productcode=p.productcode inner join productlines as pl on p.productline=pl.productline group by o.ordernumber,o.orderdate having cantidadlineasproducto > 1 order by o.ordernumber;


/**
🧾 Order Details (detalle de pedido)

“Mostrame todas las líneas de detalle con nombre del producto y número de pedido.”

“Quiero saber cuánto dinero generó cada producto sumando todas sus ventas.”

“Listame las líneas de detalle donde el precio unitario del pedido es mayor al MSRP.”

“Mostrame la orden con el monto total más alto.”
*/
--1
select od.ordernumber,od.productcode,p.productname from orderdetails as od inner join products as p on od.productcode=p.productcode;

--2
select p.productname,sum(od.priceeach*od.quantityordered) from products as p inner join orderdetails as od on p.productcode=od.productcode inner join orders on od.ordernumber=orders.ordernumber where orders.status <> 'Cancelled' group by p.productname;

--3
select od.ordernumber, p.productname from orderdetails as od inner join products as p on od.productcode=p.productcode where od.priceeach> p.msrp;

--4
select ordernumber, sum(priceeach*quantityordered) as total from orderdetails group by ordernumber order by total desc limit 1;


/**
💸 Pagos

“Mostrame todos los pagos con el nombre del cliente y el monto.”

“Quiero saber cuál fue el pago más grande realizado por cada cliente.”

“Mostrame los clientes que nunca hicieron un pago.”

“Listame los pagos agrupados por año y cuánto se recaudó por año.”
*/

--1
select c.customername,p.amount,p.paymentdate from customers as c inner join payments as p on c.customernumber=p.customernumber;

--2
select c.customername,max(p.amount) from customers c inner join payments p on c.customernumber=p.customernumber group by c.customername;

--3
select c.customername,p.amount,p.paymentdate from customers as c left join payme
nts as p on c.customernumber=p.customernumber where p.customernumber is null;

--4
select year(paymentdate), sum(amount) from payments group by year(paymentdate);




/**
🤯 Consultas más complejas (ideal para practicar subqueries o joins anidados)

“Mostrame los clientes que han comprado cada línea de producto existente.”
→ tipo “división relacional”

“Decime cuál empleado generó más ventas (sumatoria de pedidos de sus clientes).”

“Mostrame los países donde los clientes gastaron más que el promedio global.”

“Quiero encontrar los productos cuya suma vendida está por encima del límite de crédito promedio de los clientes.”

“Listame pedidos con el monto total y comparalo con el pago total del cliente (pague o no lo pague totalmente).”

“Mostrame los clientes cuyo representante de ventas trabaja en una oficina distinta a su país.”

“Dame los top 3 clientes por monto total gastado.”

“Mostrame los 5 productos menos vendidos.”
*/


--1
SELECT c.customerName
FROM customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM productlines pl
    WHERE NOT EXISTS (
        SELECT 1
        FROM orders o
        JOIN orderdetails od ON o.orderNumber = od.orderNumber
        JOIN products p ON od.productCode = p.productCode
        WHERE o.customerNumber = c.customerNumber
          AND p.productLine = pl.productLine
    )
);


--2
select e.employeenumber,concat(e.lastname,', ',e.firstname) as nombre, sum(od.priceeach*od.quantityordered) as total from employees as e inner join customers as c on e.employeenumber=c.salesrepemployeenumber inner join orders as o on c.customernumber=o.customernumber inner join orderdetails as od on o.ordernumber=od.ordernumber group by e.employeenumber,nombre;

--3
select c.country,sum(p.amount) as totalPais from customers c join payments p on
c.customernumber=p.customernumber group by c.country having totalPais > (select avg(amount) from payments);

--4
select p.productname, sum(od.quantityordered*od.priceeach) as totalvendido from
products p join orderdetails od on p.productcode=od.productcode group by p.productname having totalvendido> (select avg(creditlimit) from customers);

--5
select o.ordernumber,c.customername, sum(od.priceeach*od.quantityordered) as totalPedido, ifnull(sum(p.amount),0) as totalPagado from orders o join customers c on o.customernumber=c.customernumber join orderdetails od on o.ordernumber=od.ordernumber left join payments p on c.customernumber=p.customernumber group by o.ordernumber,c.customername;

--6
select c.customername,concat(e.lastname,', ', e.firstname) as representante, o.country as paisoficina, c.country as paisCliente from customers c join employees e on c.salesrepemployeenumber=e.employeenumber join offices o on e.officecode=o.officecode where o.country<>c.country;

--7
select c.customername, sum(p.amount) as totalgastado from customers c inner join payments p on c.customernumber=p.customernumber group by c.customername order by totalgastado desc limit 4;

--8
select p.productcode,p.productname,sum(od.quantityordered) as totalvendido from
products p join orderdetails od on p.productcode=od.productcode group by p.productcode,p.productname order by totalvendido asc limit 10;


/**
“Mostrame los clientes que, en total, pagaron menos dinero del que gastaron en pedidos.”
*/
SELECT 
    c.customerName,
    IFNULL(p.totalPagado, 0) AS pagado,
    IFNULL(o.totalPedido, 0) AS pedido
FROM customers c
LEFT JOIN (
    SELECT customerNumber, SUM(amount) AS totalPagado
    FROM payments
    GROUP BY customerNumber
) p ON c.customerNumber = p.customerNumber
LEFT JOIN (
    SELECT o.customerNumber, SUM(od.quantityOrdered * od.priceEach) AS totalPedido
    FROM orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    GROUP BY o.customerNumber
) o ON c.customerNumber = o.customerNumber
WHERE IFNULL(p.totalPagado, 0) < IFNULL(o.totalPedido, 0);


/*
“Mostrame los productos que solo fueron vendidos a clientes cuyo creditLimit está por encima del promedio.”
*/
select p.productname from products p where not exists (select 1 from orderdetails od inner join orders o on od.ordernumber=o.ordernumber inner join customers c on o.customernumber=c.customernumber where od.productcode=p.productcode and c.creditlimit <= (select avg(creditlimit) from customers));


/*
“Mostrame los empleados cuyos clientes generan ventas por encima del promedio global de ventas.”
*/
set @promedio:=(select avg(total) from (select sum(od.quantityordered*od.priceeach) as total from orderdetails od inner join orders o on od.ordernumber=o.ordernumber inner join customers c on o.customernumber=c.customernumber group by c.customernumber) AS sub);

select e.employeenumber,concat(e.lastname,', ',e.firstname) as empleado,sum(od.quantityordered*od.priceeach) as total from employees e inner join customers c on e.employeenumber=c.salesrepemployeenumber inner join orders o on c.customernumber=o.customernumber inner join orderdetails od on
o.ordernumber=od.ordernumber group by e.employeenumber,empleado having total>@promedio;



