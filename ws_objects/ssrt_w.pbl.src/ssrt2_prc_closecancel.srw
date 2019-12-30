$PBExportHeader$ssrt2_prc_closecancel.srw
$PBExportComments$[hcjung] 마감취소
forward
global type ssrt2_prc_closecancel from w_a_inq_s
end type
end forward

global type ssrt2_prc_closecancel from w_a_inq_s
integer height = 528
windowstate windowstate = normal!
end type
global ssrt2_prc_closecancel ssrt2_prc_closecancel

type variables
String is_new = 'N'
end variables

event ue_ok;call super::ue_ok;STRING 	ls_remark, 			ls_partner, 		ls_msg, ls_regtype, &
			ls_paydt,			ls_bf_op , 			ls_bf_remark
DATE   	ldt_closedt,		ldt_new_closedt,	ldt_paydt, &
			ldt_bf_closedt, 	ldt_bf_workdt
DEC{2}	ldc_sum
//=========================================================================
ls_partner 		= trim(dw_cond.Object.partner[1])
ls_remark 		= trim(dw_cond.Object.remark[1])
ldt_closedt 	= dw_cond.Object.closedt[1]

IF IsNull(ls_remark) then ls_remark = ""

//------------------
// Update
Integer li_rtn
ls_msg = "마감일 : " + String(ldt_closedt, 'mm-dd-yyyy') + "~t~n  Shop 마감을 취소 하겠습니까?(Y/N) "
li_rtn  = MessageBox("Result", ls_msg, Exclamation!, OKCancel!, 2)

//1. SHOPCLOSEMST  Update
IF li_rtn = 1 THEN
	IF is_new = 'Y' then
		RollBack;
		f_msg_sql_err(title, " Insert Error ( SHOPCLOSEMST )")
		Return 
	ELSE
		//1 History 로 넘긴 후.
//		SELECT OPERATOR, REMARK
//		  INTO :ls_bf_op, :ls_bf_remark
//		  FROM SHOPCLOSEMST
//		 WHERE PARTNER = :ls_partner; 
		
	  	INSERT INTO SHOPCLOSEMSTH  
      	(PARTNER, CLOSEDT, OPERATOR, WORKDT, REMARK, LOG_STATUS)  
  	  	VALUES 
	      (:ls_partner, :ldt_closedt, :gs_user_id, sysdate, :ls_remark, 'CANCEL');		
			
		IF sqlca.sqlcode < 0 THEN
			ROLLBACK;
			f_msg_sql_err(title, " Insert Error ( SHOPCLOSEMSTH )")
			RETURN
		END IF
		
		//2 Update
		UPDATE SHOPCLOSEMST  
     		SET CLOSEDT  = :ldt_closedt,
			    OPERATOR = :gs_user_id,
				 REMARK	 = :ls_remark,
				 WORKDT   = sysdate
 	    WHERE PARTNER  = :ls_partner;
		  
		IF sqlca.sqlcode < 0 THEN
			ROLLBACK;
			f_msg_sql_err(title, " Update Error ( SHOPCLOSEMST )")
			RETURN
		END IF
	
		// Dailypayment 에 Insert
	  	DELETE DAILYPAYMENT_SUM  
       WHERE SHOPID =  :ls_partner
		   AND PAYDT = :ldt_closedt;
		  
		IF sqlca.sqlcode < 0 THEN
			f_msg_sql_err(title, " Insert Error( DAILYPAYMENT_SUM )")
			ROLLBACK;
			RETURN 			
		END IF
	END IF	
	COMMIT;
	f_msg_info(3000,This.Title,"Shop Closing Cancel");
	RETURN
ELSE
	RETURN
END IF
end event

event open;call super::open;date ldt_dt
String ls_closedt

select closedt-1 into :ldt_dt 
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

on ssrt2_prc_closecancel.create
call super::create
end on

on ssrt2_prc_closecancel.destroy
call super::destroy
end on

type dw_cond from w_a_inq_s`dw_cond within ssrt2_prc_closecancel
integer width = 2286
integer height = 296
string dataobject = "ssrt_cnd_prc_shopclose"
end type

type p_ok from w_a_inq_s`p_ok within ssrt2_prc_closecancel
end type

type p_close from w_a_inq_s`p_close within ssrt2_prc_closecancel
end type

type gb_cond from w_a_inq_s`gb_cond within ssrt2_prc_closecancel
integer width = 2336
integer height = 376
integer taborder = 0
end type

type dw_detail from w_a_inq_s`dw_detail within ssrt2_prc_closecancel
boolean visible = false
integer x = 46
integer y = 412
integer width = 2336
integer height = 200
end type

