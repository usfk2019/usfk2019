$PBExportHeader$ssrt_prc_shopclose.srw
$PBExportComments$[1hera] Shop 마감
forward
global type ssrt_prc_shopclose from w_a_inq_s
end type
end forward

global type ssrt_prc_shopclose from w_a_inq_s
integer height = 672
windowstate windowstate = normal!
end type
global ssrt_prc_shopclose ssrt_prc_shopclose

type variables
String is_new = 'N'
end variables

event ue_ok;call super::ue_ok;String 	ls_remark, 			ls_partner, 		ls_msg, ls_regtype, &
			ls_paydt
date   	ldt_closedt,		ldt_new_closedt,		ldt_paydt
dec{2}	ldc_sum,          ld_vatsum

date 		ldt_bf_closedt, 	ldt_bf_workdt
String 	ls_bf_op , 			ls_bf_remark
//=========================================================================
ls_partner 		= trim(dw_cond.Object.partner[1])
ls_remark 		= trim(dw_cond.Object.remark[1])
ldt_closedt 	= dw_cond.Object.closedt[1]
ldt_bf_closedt	= ldt_closedt

ldt_paydt 		= dw_cond.Object.closedt[1]
ls_paydt 		=  String(ldt_closedt, 'yyyymmdd')

IF IsNull(ls_remark) then ls_remark = ""

//------------------
// Update
Integer li_rtn
ls_msg = "마감일 : " + String(ldt_closedt, 'mm-dd-yyyy') + "~t~n  Shop 마감 하겠습니까?(Y/N) "
li_rtn  = MessageBox("Result", ls_msg, &
		Exclamation!, OKCancel!, 2)
//1. SHOPCLOSEMST  Update
IF li_rtn = 1 THEN
	ldt_new_closedt = RelativeDate ( ldt_closedt, 1 )
	IF is_new = 'Y' then
	  INSERT INTO SHOPCLOSEMST  
         ( 	PARTNER, 		CLOSEDT, 		OPERATOR, 
				WORKDT, 			REMARK )  
  	  VALUES 
	      ( 	:ls_partner, 	:ldt_new_closedt, 	:gs_user_id, 
				sysdate, 		:ls_remark		) ;
		IF sqlca.sqlcode < 0 THEN
			RollBack;
			f_msg_sql_err(title, " Insert Error ( SHOPCLOSEMST )")
			Return 
		END IF		
		
	  INSERT INTO SHOPCLOSEMSTH  
         ( 	PARTNER, 			CLOSEDT, 			OPERATOR, 
				WORKDT, 				REMARK,				LOG_STATUS )  
  	  VALUES 
	      ( 	:ls_partner, 		:ldt_new_closedt, 	:gs_user_id, 
				sysdate, 			:ls_remark,			'EXECUTE' 	);				
	
	   IF sqlca.sqlcode < 0 THEN
			RollBack;
			f_msg_sql_err(title, " Insert Error ( SHOPCLOSEMSTH )")
			Return 
		END IF				
			
	ELSE
		//1 History 로 넘긴 후.
//		select OPERATOR, 	WORKDT, 				REMARK
//		  INTO :ls_bf_op, :ldt_bf_workdt, 	:ls_bf_remark
//		  FROM SHOPCLOSEMST
//			 WHERE partner = :ls_partner 
//			   AND CLOSEDT = :ldt_bf_closedt ;
		
	  INSERT INTO SHOPCLOSEMSTH  
         ( 	PARTNER, 			CLOSEDT, 			OPERATOR, 
				WORKDT, 				REMARK,				LOG_STATUS )  
  	  VALUES 
	      ( 	:ls_partner, 		:ldt_new_closedt, 	:gs_user_id, 
				SYSDATE, 			:ls_remark,				'EXECUTE' 	)   ;		
			
		IF sqlca.sqlcode < 0 THEN
			RollBack;
			f_msg_sql_err(title, " Insert Error ( SHOPCLOSEMSTH )")
			Return 
		END IF
		//2 Update
		UPDATE SHOPCLOSEMST  
     		SET CLOSEDT = :ldt_new_closedt  
 	    WHERE PARTNER = :ls_partner    ;
		  
		IF sqlca.sqlcode < 0 THEN
			RollBack;
			f_msg_sql_err(title, " Update Error ( SHOPCLOSEMST )")
			Return 
		END IF
	END IF
	
	//2. DAILYPAYMENT_SUM iNSERT
	DECLARE read_regcod CURSOR FOR  
	  SELECT CODE	 FROM SYSCOD2T  
	   WHERE GRCODE = 'Z200'              ;
		
	OPEN read_regcod;
	FETCH read_regcod 			INTO :ls_regtype;
	//---------------------------------------------------------------
	DO WHILE SQLCA.SQLCODE = 0 
		//일 마감.
		// 2019.05.07 Vat Summary 추가 Modified by Han
		SELECT SUM(A.PAYAMT), SUM(NVL(A.TAXAMT,0))
		  INTO :ldc_sum     , :ld_vatsum
		  FROM DAILYPAYMENT A, REGCODMST B
		 WHERE A.REGCOD 								= B.REGCOD
		   AND TO_CHAR(A.PAYDT, 'YYYYMMDD')  	= :ls_paydt
		   AND A.SHOPID 								= :ls_partner
			AND B.REGTYPE 								= :LS_REGTYPE ;

		IF ISNull(ldc_sum) OR sqlca.sqlcode <> 0 THEN ldc_sum = 0
		
		// Dailypayment 에 Insert
	  INSERT INTO DAILYPAYMENT_SUM (PAYDT     , SHOPID     , REGTYPE    , SUM     , TAX )  
  	                        VALUES (:ldt_paydt, :ls_partner, :ls_regtype, :ldc_sum, :ld_vatsum);		
		IF sqlca.sqlcode < 0 THEN
			f_msg_sql_err(title, " Insert Error( DAILYPAYMENT_SUM )")
			RollBack;
			Return 			
		END IF
		
		FETCH read_regcod INTO :ls_regtype;
	LOOP
	CLOSE read_regcod ;
	//=============================================
	commit ;
	f_msg_info(3000,This.Title,"Shop Closing");
	return
ELSE
	return
END IF



end event

event open;call super::open;date ldt_dt
String ls_closedt

select closedt into :ldt_dt 
  from shopclosemst
 WHERE partner = :GS_SHOPID ;
 
IF sqlca.sqlcode = 0  then
	is_new = 'N'
else
	is_new = 'Y'
END IF

IF is_new = 'Y' then
	ldt_dt = date(fdt_get_dbserver_now())
END IF

dw_cond.Object.partner[1] =  GS_SHOPID
dw_cond.Object.closedt[1] =  ldt_dt
dw_cond.SetFocus()
dw_cond.SetRow(1)
dw_cond.SetColumn("remark")
PostEvent("resize")
end event

on ssrt_prc_shopclose.create
call super::create
end on

on ssrt_prc_shopclose.destroy
call super::destroy
end on

type dw_cond from w_a_inq_s`dw_cond within ssrt_prc_shopclose
integer width = 2286
integer height = 296
string dataobject = "ssrt_cnd_prc_shopclose"
end type

type p_ok from w_a_inq_s`p_ok within ssrt_prc_shopclose
end type

type p_close from w_a_inq_s`p_close within ssrt_prc_shopclose
end type

type gb_cond from w_a_inq_s`gb_cond within ssrt_prc_shopclose
integer width = 2336
integer height = 376
integer taborder = 0
end type

type dw_detail from w_a_inq_s`dw_detail within ssrt_prc_shopclose
boolean visible = false
integer x = 46
integer y = 412
integer width = 2336
integer height = 200
end type

