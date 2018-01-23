-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2015 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : example_create_dimension.sql                                    |
-- | CLASS    : Examples                                                        |
-- | PURPOSE  : Example SQL script to create a dimension object.                |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

CREATE DIMENSION dim_clothes
		LEVEL upc		IS retail_tab.upc
		LEVEL style		IS retail_tab.style
		LEVEL class		IS retail_tab.class
		LEVEL department	IS retail_tab.department
		LEVEL store		IS retail_tab.store
		LEVEL region	IS retail_tab.region
		LEVEL company	IS retail_tab.company
	HIERARCHY sales_rollup (
		upc		CHILD OF
		style		CHILD OF
		class		CHILD OF
		department	CHILD OF
		store		CHILD OF
		region	CHILD OF
		company)
	ATTRIBUTE style	DETERMINES (color)
	ATTRIBUTE upc	DETERMINES (item_size);

