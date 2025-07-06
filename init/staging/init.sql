CREATE SCHEMA IF NOT EXISTS bikes_store_staging;
CREATE TABLE bikes_store_staging.shipmethod (
    shipmethodid integer NOT NULL,
    name text NOT NULL,
    shipbase numeric DEFAULT 0.00 NOT NULL,
    shiprate numeric DEFAULT 0.00 NOT NULL,
    rowguid uuid NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_ShipMethod_ShipBase" CHECK ((shipbase > 0.00)),
    CONSTRAINT "CK_ShipMethod_ShipRate" CHECK ((shiprate > 0.00))
);

ALTER TABLE ONLY bikes_store_staging.shipmethod
    ADD CONSTRAINT "PK_ShipMethod_ShipMethodID" PRIMARY KEY (shipmethodid);

CREATE TABLE bikes_store_staging.person (
    businessentityid integer NOT NULL,
    persontype character(2) NOT NULL,
    namestyle text NOT NULL,
    title character varying(8),
    firstname text NOT NULL,
    middlename text,
    lastname text NOT NULL,
    suffix character varying(10),
    emailpromotion integer DEFAULT 0 NOT NULL,
    additionalcontactinfo xml,
    demographics xml,
    rowguid uuid NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_Person_EmailPromotion" CHECK (((emailpromotion >= 0) AND (emailpromotion <= 2))),
    CONSTRAINT "CK_Person_PersonType" CHECK (((persontype IS NULL) OR (upper((persontype)::text) = ANY (ARRAY['SC'::text, 'VC'::text, 'IN'::text, 'EM'::text, 'SP'::text, 'GC'::text]))))
);

CREATE TABLE bikes_store_staging.employee (
    businessentityid integer NOT NULL,
    nationalidnumber character varying(15) NOT NULL,
    loginid character varying(256) NOT NULL,
    jobtitle character varying(50) NOT NULL,
    birthdate date NOT NULL,
    maritalstatus character(1) NOT NULL,
    gender character(1) NOT NULL,
    hiredate date NOT NULL,
    salariedflag text  NOT NULL,
    vacationhours smallint DEFAULT 0 NOT NULL,
    sickleavehours smallint DEFAULT 0 NOT NULL,
    currentflag text NOT NULL,
    rowguid uuid NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    organizationnode character varying DEFAULT '/'::character varying,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_Employee_BirthDate" CHECK (((birthdate >= '1930-01-01'::date) AND (birthdate <= (now() - '18 years'::interval)))),
    CONSTRAINT "CK_Employee_Gender" CHECK ((upper((gender)::text) = ANY (ARRAY['M'::text, 'F'::text]))),
    CONSTRAINT "CK_Employee_HireDate" CHECK (((hiredate >= '1996-07-01'::date) AND (hiredate <= (now() + '1 day'::interval)))),
    CONSTRAINT "CK_Employee_MaritalStatus" CHECK ((upper((maritalstatus)::text) = ANY (ARRAY['M'::text, 'S'::text]))),
    CONSTRAINT "CK_Employee_SickLeaveHours" CHECK (((sickleavehours >= 0) AND (sickleavehours <= 120))),
    CONSTRAINT "CK_Employee_VacationHours" CHECK (((vacationhours >= '-40'::integer) AND (vacationhours <= 240)))
);

CREATE TABLE bikes_store_staging.product (
    productid integer NOT NULL,
    name text NOT NULL,
    productnumber character varying(25) NOT NULL,
    makeflag text  NOT NULL,
    finishedgoodsflag text NOT NULL,
    color character varying(15),
    safetystocklevel smallint NOT NULL,
    reorderpoint smallint NOT NULL,
    standardcost numeric NOT NULL,
    listprice numeric NOT NULL,
    size character varying(5),
    sizeunitmeasurecode character(3),
    weightunitmeasurecode character(3),
    weight numeric(8,2),
    daystomanufacture integer NOT NULL,
    productline character(2),
    class character(2),
    style character(2),
    productsubcategoryid integer,
    productmodelid integer,
    sellstartdate timestamp without time zone NOT NULL,
    sellenddate timestamp without time zone,
    discontinueddate timestamp without time zone,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_Product_Class" CHECK (((upper((class)::text) = ANY (ARRAY['L'::text, 'M'::text, 'H'::text])) OR (class IS NULL))),
    CONSTRAINT "CK_Product_DaysToManufacture" CHECK ((daystomanufacture >= 0)),
    CONSTRAINT "CK_Product_ListPrice" CHECK ((listprice >= 0.00)),
    CONSTRAINT "CK_Product_ProductLine" CHECK (((upper((productline)::text) = ANY (ARRAY['S'::text, 'T'::text, 'M'::text, 'R'::text])) OR (productline IS NULL))),
    CONSTRAINT "CK_Product_ReorderPoint" CHECK ((reorderpoint > 0)),
    CONSTRAINT "CK_Product_SafetyStockLevel" CHECK ((safetystocklevel > 0)),
    CONSTRAINT "CK_Product_SellEndDate" CHECK (((sellenddate >= sellstartdate) OR (sellenddate IS NULL))),
    CONSTRAINT "CK_Product_StandardCost" CHECK ((standardcost >= 0.00)),
    CONSTRAINT "CK_Product_Style" CHECK (((upper((style)::text) = ANY (ARRAY['W'::text, 'M'::text, 'U'::text])) OR (style IS NULL))),
    CONSTRAINT "CK_Product_Weight" CHECK ((weight > 0.00))
);

CREATE TABLE bikes_store_staging.customer (
    customerid integer NOT NULL,
    personid integer,
    storeid integer,
    territoryid integer,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.currencyrate (
    currencyrateid integer NOT NULL,
    currencyratedate timestamp without time zone NOT NULL,
    fromcurrencycode character(3) NOT NULL,
    tocurrencycode character(3) NOT NULL,
    averagerate numeric NOT NULL,
    endofdayrate numeric NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.store (
    businessentityid integer NOT NULL,
    name text NOT NULL,
    salespersonid integer,
    demographics xml,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.shoppingcartitem (
    shoppingcartitemid integer NOT NULL,
    shoppingcartid character varying(50) NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    productid integer NOT NULL,
    datecreated timestamp without time zone DEFAULT now() NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_ShoppingCartItem_Quantity" CHECK ((quantity >= 1))
);

CREATE TABLE bikes_store_staging.specialoffer (
    specialofferid integer NOT NULL,
    description character varying(255) NOT NULL,
    discountpct numeric DEFAULT 0.00 NOT NULL,
    type character varying(50) NOT NULL,
    category character varying(50) NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone NOT NULL,
    minqty integer DEFAULT 0 NOT NULL,
    maxqty integer,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SpecialOffer_DiscountPct" CHECK ((discountpct >= 0.00)),
    CONSTRAINT "CK_SpecialOffer_EndDate" CHECK ((enddate >= startdate)),
    CONSTRAINT "CK_SpecialOffer_MaxQty" CHECK ((maxqty >= 0)),
    CONSTRAINT "CK_SpecialOffer_MinQty" CHECK ((minqty >= 0))
);
CREATE TABLE bikes_store_staging.salesorderdetail (
    salesorderid integer NOT NULL,
    salesorderdetailid integer NOT NULL,
    carriertrackingnumber character varying(25),
    orderqty smallint NOT NULL,
    productid integer NOT NULL,
    specialofferid integer NOT NULL,
    unitprice numeric NOT NULL,
    unitpricediscount numeric DEFAULT 0.0 NOT NULL,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SalesOrderDetail_OrderQty" CHECK ((orderqty > 0)),
    CONSTRAINT "CK_SalesOrderDetail_UnitPrice" CHECK ((unitprice >= 0.00)),
    CONSTRAINT "CK_SalesOrderDetail_UnitPriceDiscount" CHECK ((unitpricediscount >= 0.00))
);
CREATE TABLE bikes_store_staging.salesorderheader (
    salesorderid integer NOT NULL,
    revisionnumber smallint DEFAULT 0 NOT NULL,
    orderdate timestamp without time zone DEFAULT now() NOT NULL,
    duedate timestamp without time zone NOT NULL,
    shipdate timestamp without time zone,
    status smallint DEFAULT 1 NOT NULL,
    onlineorderflag text NOT NULL,
    purchaseordernumber text,
    accountnumber text,
    customerid integer NOT NULL,
    salespersonid integer,
    territoryid integer,
    billtoaddressid integer NOT NULL,
    shiptoaddressid integer NOT NULL,
    shipmethodid integer NOT NULL,
    creditcardid integer,
    creditcardapprovalcode character varying(15),
    currencyrateid integer,
    subtotal numeric DEFAULT 0.00 NOT NULL,
    taxamt numeric DEFAULT 0.00 NOT NULL,
    freight numeric DEFAULT 0.00 NOT NULL,
    totaldue numeric,
    comment character varying(128),
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SalesOrderHeader_DueDate" CHECK ((duedate >= orderdate)),
    CONSTRAINT "CK_SalesOrderHeader_Freight" CHECK ((freight >= 0.00)),
    CONSTRAINT "CK_SalesOrderHeader_ShipDate" CHECK (((shipdate >= orderdate) OR (shipdate IS NULL))),
    CONSTRAINT "CK_SalesOrderHeader_Status" CHECK (((status >= 0) AND (status <= 8))),
    CONSTRAINT "CK_SalesOrderHeader_SubTotal" CHECK ((subtotal >= 0.00)),
    CONSTRAINT "CK_SalesOrderHeader_TaxAmt" CHECK ((taxamt >= 0.00))
);
CREATE TABLE bikes_store_staging.salesorderheadersalesreason (
    salesorderid integer NOT NULL,
    salesreasonid integer NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.specialofferproduct (
    specialofferid integer NOT NULL,
    productid integer NOT NULL,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.salesperson (
    businessentityid integer NOT NULL,
    territoryid integer,
    salesquota numeric,
    bonus numeric DEFAULT 0.00 NOT NULL,
    commissionpct numeric DEFAULT 0.00 NOT NULL,
    salesytd numeric DEFAULT 0.00 NOT NULL,
    saleslastyear numeric DEFAULT 0.00 NOT NULL,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SalesPerson_Bonus" CHECK ((bonus >= 0.00)),
    CONSTRAINT "CK_SalesPerson_CommissionPct" CHECK ((commissionpct >= 0.00)),
    CONSTRAINT "CK_SalesPerson_SalesLastYear" CHECK ((saleslastyear >= 0.00)),
    CONSTRAINT "CK_SalesPerson_SalesQuota" CHECK ((salesquota > 0.00)),
    CONSTRAINT "CK_SalesPerson_SalesYTD" CHECK ((salesytd >= 0.00))
);

CREATE TABLE bikes_store_staging.salespersonquotahistory (
    businessentityid integer NOT NULL,
    quotadate timestamp without time zone NOT NULL,
    salesquota numeric NOT NULL,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
    CONSTRAINT "CK_SalesPersonQuotaHistory_SalesQuota" CHECK ((salesquota > 0.00))
);
CREATE TABLE bikes_store_staging.salesreason (
    salesreasonid integer NOT NULL,
    name text NOT NULL,
    reasontype text NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);
CREATE TABLE bikes_store_staging.salesterritory (
    territoryid integer NOT NULL,
    name text NOT NULL,
    countryregioncode character varying(3) NOT NULL,
    "group" character varying(50) NOT NULL,
    salesytd numeric DEFAULT 0.00 NOT NULL,
    saleslastyear numeric DEFAULT 0.00 NOT NULL,
    costytd numeric DEFAULT 0.00 NOT NULL,
    costlastyear numeric DEFAULT 0.00 NOT NULL,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SalesTerritory_CostLastYear" CHECK ((costlastyear >= 0.00)),
    CONSTRAINT "CK_SalesTerritory_CostYTD" CHECK ((costytd >= 0.00)),
    CONSTRAINT "CK_SalesTerritory_SalesLastYear" CHECK ((saleslastyear >= 0.00)),
    CONSTRAINT "CK_SalesTerritory_SalesYTD" CHECK ((salesytd >= 0.00))
);
CREATE TABLE bikes_store_staging.salesterritoryhistory (
    businessentityid integer NOT NULL,
    territoryid integer NOT NULL,
    startdate timestamp without time zone NOT NULL,
    enddate timestamp without time zone,
    rowguid uuid  NOT NULL,
    modifieddate timestamp without time zone DEFAULT now() NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT "CK_SalesTerritoryHistory_EndDate" CHECK (((enddate >= startdate) OR (enddate IS NULL)))
);

CREATE TABLE bikes_store_staging.currency (
	currencycode bpchar(3) NOT NULL, -- The ISO code for the Currency.
	"name" text NOT NULL, -- Currency name.
	modifieddate timestamp NOT NULL DEFAULT now(),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
	CONSTRAINT "PK_Currency_CurrencyCode" PRIMARY KEY (currencycode)
);

CREATE SEQUENCE bikes_store_staging.product_productid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: product_productid_seq; Type: SEQUENCE OWNED BY; Schema: production; Owner: -
--

ALTER SEQUENCE bikes_store_staging.product_productid_seq OWNED BY bikes_store_staging.product.productid;

CREATE SEQUENCE bikes_store_staging.currencyrate_currencyrateid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: currencyrate_currencyrateid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.currencyrate_currencyrateid_seq OWNED BY bikes_store_staging.currencyrate.currencyrateid;


--
-- Name: customer_customerid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.customer_customerid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: customer_customerid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.customer_customerid_seq OWNED BY bikes_store_staging.customer.customerid;


--
-- Name: salesorderdetail_salesorderdetailid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.salesorderdetail_salesorderdetailid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salesorderdetail_salesorderdetailid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.salesorderdetail_salesorderdetailid_seq OWNED BY bikes_store_staging.salesorderdetail.salesorderdetailid;


--
-- Name: salesorderheader_salesorderid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.salesorderheader_salesorderid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salesorderheader_salesorderid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.salesorderheader_salesorderid_seq OWNED BY bikes_store_staging.salesorderheader.salesorderid;


--
-- Name: salesreason_salesreasonid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.salesreason_salesreasonid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salesreason_salesreasonid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.salesreason_salesreasonid_seq OWNED BY bikes_store_staging.salesreason.salesreasonid;


--
-- Name: salesterritory_territoryid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.salesterritory_territoryid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salesterritory_territoryid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.salesterritory_territoryid_seq OWNED BY bikes_store_staging.salesterritory.territoryid;


--
-- Name: shoppingcartitem_shoppingcartitemid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.shoppingcartitem_shoppingcartitemid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shoppingcartitem_shoppingcartitemid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.shoppingcartitem_shoppingcartitemid_seq OWNED BY bikes_store_staging.shoppingcartitem.shoppingcartitemid;


--
-- Name: specialoffer_specialofferid_seq; Type: SEQUENCE; Schema: sales; Owner: -
--

CREATE SEQUENCE bikes_store_staging.specialoffer_specialofferid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: specialoffer_specialofferid_seq; Type: SEQUENCE OWNED BY; Schema: sales; Owner: -
--

ALTER SEQUENCE bikes_store_staging.specialoffer_specialofferid_seq OWNED BY bikes_store_staging.specialoffer.specialofferid;


--
-- Name: product productid; Type: DEFAULT; Schema: production; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.product ALTER COLUMN productid SET DEFAULT nextval('bikes_store_staging.product_productid_seq'::regclass);


--
-- Name: productcategory productcategoryid; Type: DEFAULT; Schema: production; Owner: -
--

--
-- Name: currencyrate currencyrateid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.currencyrate ALTER COLUMN currencyrateid SET DEFAULT nextval('bikes_store_staging.currencyrate_currencyrateid_seq'::regclass);


--
-- Name: customer customerid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.customer ALTER COLUMN customerid SET DEFAULT nextval('bikes_store_staging.customer_customerid_seq'::regclass);


--
-- Name: salesorderdetail salesorderdetailid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderdetail ALTER COLUMN salesorderdetailid SET DEFAULT nextval('bikes_store_staging.salesorderdetail_salesorderdetailid_seq'::regclass);


--
-- Name: salesorderheader salesorderid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader ALTER COLUMN salesorderid SET DEFAULT nextval('bikes_store_staging.salesorderheader_salesorderid_seq'::regclass);


--
-- Name: salesreason salesreasonid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesreason ALTER COLUMN salesreasonid SET DEFAULT nextval('bikes_store_staging.salesreason_salesreasonid_seq'::regclass);


--
-- Name: salesterritory territoryid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesterritory ALTER COLUMN territoryid SET DEFAULT nextval('bikes_store_staging.salesterritory_territoryid_seq'::regclass);


--
-- Name: shoppingcartitem shoppingcartitemid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.shoppingcartitem ALTER COLUMN shoppingcartitemid SET DEFAULT nextval('bikes_store_staging.shoppingcartitem_shoppingcartitemid_seq'::regclass);


--
-- Name: specialoffer specialofferid; Type: DEFAULT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.specialoffer ALTER COLUMN specialofferid SET DEFAULT nextval('bikes_store_staging.specialoffer_specialofferid_seq'::regclass);


--
-- Name: product_productid_seq; Type: SEQUENCE SET; Schema: production; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.product_productid_seq', 1, false);


--
-- Name: productcategory_productcategoryid_seq; Type: SEQUENCE SET; Schema: production; Owner: -
--



--
-- Name: currencyrate_currencyrateid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.currencyrate_currencyrateid_seq', 1, false);


--
-- Name: customer_customerid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.customer_customerid_seq', 1, false);


--
-- Name: salesorderdetail_salesorderdetailid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.salesorderdetail_salesorderdetailid_seq', 1, false);


--
-- Name: salesorderheader_salesorderid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.salesorderheader_salesorderid_seq', 1, false);


--
-- Name: salesreason_salesreasonid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.salesreason_salesreasonid_seq', 1, false);


--
-- Name: salesterritory_territoryid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.salesterritory_territoryid_seq', 1, false);


--
-- Name: shoppingcartitem_shoppingcartitemid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.shoppingcartitem_shoppingcartitemid_seq', 1, false);


--
-- Name: specialoffer_specialofferid_seq; Type: SEQUENCE SET; Schema: sales; Owner: -
--

SELECT pg_catalog.setval('bikes_store_staging.specialoffer_specialofferid_seq', 1, false);


--
-- Name: employee PK_Employee_BusinessEntityID; Type: CONSTRAINT; Schema: humanresources; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.person
    ADD CONSTRAINT "PK_Person_BusinessEntityID" PRIMARY KEY (businessentityid);

ALTER TABLE bikes_store_staging.person CLUSTER ON "PK_Person_BusinessEntityID";


ALTER TABLE ONLY bikes_store_staging.employee
    ADD CONSTRAINT "PK_Employee_BusinessEntityID" PRIMARY KEY (businessentityid);

ALTER TABLE bikes_store_staging.employee CLUSTER ON "PK_Employee_BusinessEntityID";


--
-- Name: productcategory PK_ProductCategory_ProductCategoryID; Type: CONSTRAINT; Schema: production; Owner: -
--


--
-- Name: product PK_Product_ProductID; Type: CONSTRAINT; Schema: production; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.product
    ADD CONSTRAINT "PK_Product_ProductID" PRIMARY KEY (productid);

ALTER TABLE bikes_store_staging.product CLUSTER ON "PK_Product_ProductID";


--
-- Name: currencyrate PK_CurrencyRate_CurrencyRateID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.currencyrate
    ADD CONSTRAINT "PK_CurrencyRate_CurrencyRateID" PRIMARY KEY (currencyrateid);

ALTER TABLE bikes_store_staging.currencyrate CLUSTER ON "PK_CurrencyRate_CurrencyRateID";


--
-- Name: customer PK_Customer_CustomerID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.customer
    ADD CONSTRAINT "PK_Customer_CustomerID" PRIMARY KEY (customerid);

ALTER TABLE bikes_store_staging.customer CLUSTER ON "PK_Customer_CustomerID";


--
-- Name: salesorderdetail PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderdetail
    ADD CONSTRAINT "PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID" PRIMARY KEY (salesorderid, salesorderdetailid);

ALTER TABLE bikes_store_staging.salesorderdetail CLUSTER ON "PK_SalesOrderDetail_SalesOrderID_SalesOrderDetailID";


--
-- Name: salesorderheadersalesreason PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheadersalesreason
    ADD CONSTRAINT "PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID" PRIMARY KEY (salesorderid, salesreasonid);

ALTER TABLE bikes_store_staging.salesorderheadersalesreason CLUSTER ON "PK_SalesOrderHeaderSalesReason_SalesOrderID_SalesReasonID";


--
-- Name: salesorderheader PK_SalesOrderHeader_SalesOrderID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "PK_SalesOrderHeader_SalesOrderID" PRIMARY KEY (salesorderid);

ALTER TABLE bikes_store_staging.salesorderheader CLUSTER ON "PK_SalesOrderHeader_SalesOrderID";


--
-- Name: salespersonquotahistory PK_SalesPersonQuotaHistory_BusinessEntityID_QuotaDate; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salespersonquotahistory
    ADD CONSTRAINT "PK_SalesPersonQuotaHistory_BusinessEntityID_QuotaDate" PRIMARY KEY (businessentityid, quotadate);

ALTER TABLE bikes_store_staging.salespersonquotahistory CLUSTER ON "PK_SalesPersonQuotaHistory_BusinessEntityID_QuotaDate";


--
-- Name: salesperson PK_SalesPerson_BusinessEntityID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesperson
    ADD CONSTRAINT "PK_SalesPerson_BusinessEntityID" PRIMARY KEY (businessentityid);

ALTER TABLE bikes_store_staging.salesperson CLUSTER ON "PK_SalesPerson_BusinessEntityID";


--
-- Name: salesreason PK_SalesReason_SalesReasonID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesreason
    ADD CONSTRAINT "PK_SalesReason_SalesReasonID" PRIMARY KEY (salesreasonid);

ALTER TABLE bikes_store_staging.salesreason CLUSTER ON "PK_SalesReason_SalesReasonID";


--
-- Name: salesterritoryhistory PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesterritoryhistory
    ADD CONSTRAINT "PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID" PRIMARY KEY (businessentityid, startdate, territoryid);

ALTER TABLE bikes_store_staging.salesterritoryhistory CLUSTER ON "PK_SalesTerritoryHistory_BusinessEntityID_StartDate_TerritoryID";


--
-- Name: salesterritory PK_SalesTerritory_TerritoryID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesterritory
    ADD CONSTRAINT "PK_SalesTerritory_TerritoryID" PRIMARY KEY (territoryid);

ALTER TABLE bikes_store_staging.salesterritory CLUSTER ON "PK_SalesTerritory_TerritoryID";


--
-- Name: shoppingcartitem PK_ShoppingCartItem_ShoppingCartItemID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.shoppingcartitem
    ADD CONSTRAINT "PK_ShoppingCartItem_ShoppingCartItemID" PRIMARY KEY (shoppingcartitemid);

ALTER TABLE bikes_store_staging.shoppingcartitem CLUSTER ON "PK_ShoppingCartItem_ShoppingCartItemID";


--
-- Name: specialofferproduct PK_SpecialOfferProduct_SpecialOfferID_ProductID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.specialofferproduct
    ADD CONSTRAINT "PK_SpecialOfferProduct_SpecialOfferID_ProductID" PRIMARY KEY (specialofferid, productid);

ALTER TABLE bikes_store_staging.specialofferproduct CLUSTER ON "PK_SpecialOfferProduct_SpecialOfferID_ProductID";


--
-- Name: specialoffer PK_SpecialOffer_SpecialOfferID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.specialoffer
    ADD CONSTRAINT "PK_SpecialOffer_SpecialOfferID" PRIMARY KEY (specialofferid);

ALTER TABLE bikes_store_staging.specialoffer CLUSTER ON "PK_SpecialOffer_SpecialOfferID";


--
-- Name: store PK_Store_BusinessEntityID; Type: CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.store
    ADD CONSTRAINT "PK_Store_BusinessEntityID" PRIMARY KEY (businessentityid);

ALTER TABLE bikes_store_staging.store CLUSTER ON "PK_Store_BusinessEntityID";


--
-- Name: employee FK_Employee_Person_BusinessEntityID; Type: FK CONSTRAINT; Schema: humanresources; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.employee
    ADD CONSTRAINT "FK_Employee_Person_BusinessEntityID" FOREIGN KEY (businessentityid) REFERENCES bikes_store_staging.person(businessentityid);


--
-- Name: product FK_Product_ProductModel_ProductModelID; Type: FK CONSTRAINT; Schema: production; Owner: -
--


--
-- Name: product FK_Product_ProductSubcategory_ProductSubcategoryID; Type: FK CONSTRAINT; Schema: production; Owner: -
--

--
-- Name: product FK_Product_UnitMeasure_SizeUnitMeasureCode; Type: FK CONSTRAINT; Schema: production; Owner: -
--

--
-- Name: product FK_Product_UnitMeasure_WeightUnitMeasureCode; Type: FK CONSTRAINT; Schema: production; Owner: -
--


--
-- Name: currencyrate FK_CurrencyRate_Currency_FromCurrencyCode; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

--
-- Name: currencyrate FK_CurrencyRate_Currency_ToCurrencyCode; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

--
-- Name: customer FK_Customer_Person_PersonID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.customer
    ADD CONSTRAINT "FK_Customer_Person_PersonID" FOREIGN KEY (personid) REFERENCES bikes_store_staging.person(businessentityid);


--
-- Name: customer FK_Customer_SalesTerritory_TerritoryID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.customer
    ADD CONSTRAINT "FK_Customer_SalesTerritory_TerritoryID" FOREIGN KEY (territoryid) REFERENCES bikes_store_staging.salesterritory(territoryid);


--
-- Name: customer FK_Customer_Store_StoreID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.customer
    ADD CONSTRAINT "FK_Customer_Store_StoreID" FOREIGN KEY (storeid) REFERENCES bikes_store_staging.store(businessentityid);


--
-- Name: salesorderdetail FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderdetail
    ADD CONSTRAINT "FK_SalesOrderDetail_SalesOrderHeader_SalesOrderID" FOREIGN KEY (salesorderid) REFERENCES bikes_store_staging.salesorderheader(salesorderid) ON DELETE CASCADE;


--
-- Name: salesorderdetail FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderdetail
    ADD CONSTRAINT "FK_SalesOrderDetail_SpecialOfferProduct_SpecialOfferIDProductID" FOREIGN KEY (specialofferid, productid) REFERENCES bikes_store_staging.specialofferproduct(specialofferid, productid);


--
-- Name: salesorderheadersalesreason FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheadersalesreason
    ADD CONSTRAINT "FK_SalesOrderHeaderSalesReason_SalesOrderHeader_SalesOrderID" FOREIGN KEY (salesorderid) REFERENCES bikes_store_staging.salesorderheader(salesorderid) ON DELETE CASCADE;


--
-- Name: salesorderheadersalesreason FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheadersalesreason
    ADD CONSTRAINT "FK_SalesOrderHeaderSalesReason_SalesReason_SalesReasonID" FOREIGN KEY (salesreasonid) REFERENCES bikes_store_staging.salesreason(salesreasonid);


--
-- Name: salesorderheader FK_SalesOrderHeader_Address_BillToAddressID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

--
-- Name: salesorderheader FK_SalesOrderHeader_Address_ShipToAddressID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

--
-- Name: salesorderheader FK_SalesOrderHeader_CreditCard_CreditCardID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--


--
-- Name: salesorderheader FK_SalesOrderHeader_CurrencyRate_CurrencyRateID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "FK_SalesOrderHeader_CurrencyRate_CurrencyRateID" FOREIGN KEY (currencyrateid) REFERENCES bikes_store_staging.currencyrate(currencyrateid);


--
-- Name: salesorderheader FK_SalesOrderHeader_Customer_CustomerID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "FK_SalesOrderHeader_Customer_CustomerID" FOREIGN KEY (customerid) REFERENCES bikes_store_staging.customer(customerid);


--
-- Name: salesorderheader FK_SalesOrderHeader_SalesPerson_SalesPersonID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "FK_SalesOrderHeader_SalesPerson_SalesPersonID" FOREIGN KEY (salespersonid) REFERENCES bikes_store_staging.salesperson(businessentityid);


--
-- Name: salesorderheader FK_SalesOrderHeader_SalesTerritory_TerritoryID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "FK_SalesOrderHeader_SalesTerritory_TerritoryID" FOREIGN KEY (territoryid) REFERENCES bikes_store_staging.salesterritory(territoryid);


--
-- Name: salesorderheader FK_SalesOrderHeader_ShipMethod_ShipMethodID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesorderheader
    ADD CONSTRAINT "FK_SalesOrderHeader_ShipMethod_ShipMethodID" FOREIGN KEY (shipmethodid) REFERENCES bikes_store_staging.shipmethod(shipmethodid);


--
-- Name: salespersonquotahistory FK_SalesPersonQuotaHistory_SalesPerson_BusinessEntityID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salespersonquotahistory
    ADD CONSTRAINT "FK_SalesPersonQuotaHistory_SalesPerson_BusinessEntityID" FOREIGN KEY (businessentityid) REFERENCES bikes_store_staging.salesperson(businessentityid);


--
-- Name: salesperson FK_SalesPerson_Employee_BusinessEntityID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesperson
    ADD CONSTRAINT "FK_SalesPerson_Employee_BusinessEntityID" FOREIGN KEY (businessentityid) REFERENCES bikes_store_staging.employee(businessentityid);


--
-- Name: salesperson FK_SalesPerson_SalesTerritory_TerritoryID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesperson
    ADD CONSTRAINT "FK_SalesPerson_SalesTerritory_TerritoryID" FOREIGN KEY (territoryid) REFERENCES bikes_store_staging.salesterritory(territoryid);


--
-- Name: salesterritoryhistory FK_SalesTerritoryHistory_SalesPerson_BusinessEntityID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesterritoryhistory
    ADD CONSTRAINT "FK_SalesTerritoryHistory_SalesPerson_BusinessEntityID" FOREIGN KEY (businessentityid) REFERENCES bikes_store_staging.salesperson(businessentityid);


--
-- Name: salesterritoryhistory FK_SalesTerritoryHistory_SalesTerritory_TerritoryID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.salesterritoryhistory
    ADD CONSTRAINT "FK_SalesTerritoryHistory_SalesTerritory_TerritoryID" FOREIGN KEY (territoryid) REFERENCES bikes_store_staging.salesterritory(territoryid);


--
-- Name: salesterritory FK_SalesTerritory_CountryRegion_CountryRegionCode; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

--
-- Name: shoppingcartitem FK_ShoppingCartItem_Product_ProductID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.shoppingcartitem
    ADD CONSTRAINT "FK_ShoppingCartItem_Product_ProductID" FOREIGN KEY (productid) REFERENCES bikes_store_staging.product(productid);


--
-- Name: specialofferproduct FK_SpecialOfferProduct_Product_ProductID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.specialofferproduct
    ADD CONSTRAINT "FK_SpecialOfferProduct_Product_ProductID" FOREIGN KEY (productid) REFERENCES bikes_store_staging.product(productid);


--
-- Name: specialofferproduct FK_SpecialOfferProduct_SpecialOffer_SpecialOfferID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.specialofferproduct
    ADD CONSTRAINT "FK_SpecialOfferProduct_SpecialOffer_SpecialOfferID" FOREIGN KEY (specialofferid) REFERENCES bikes_store_staging.specialoffer(specialofferid);


--
-- Name: store FK_Store_BusinessEntity_BusinessEntityID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--


--
-- Name: store FK_Store_SalesPerson_SalesPersonID; Type: FK CONSTRAINT; Schema: sales; Owner: -
--

ALTER TABLE ONLY bikes_store_staging.store
    ADD CONSTRAINT "FK_Store_SalesPerson_SalesPersonID" FOREIGN KEY (salespersonid) REFERENCES bikes_store_staging.salesperson(businessentityid);



--
-- PostgreSQL database dump complete
--
