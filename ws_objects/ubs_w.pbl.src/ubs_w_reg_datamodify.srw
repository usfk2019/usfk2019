$PBExportHeader$ubs_w_reg_datamodify.srw
$PBExportComments$[jhchoi] 모바일 오더 조회 - 2009.06.21
forward
global type ubs_w_reg_datamodify from w_base
end type
type cb_clear from commandbutton within ubs_w_reg_datamodify
end type
type p_save from u_p_save within ubs_w_reg_datamodify
end type
type p_reset from u_p_reset within ubs_w_reg_datamodify
end type
type p_ok from u_p_ok within ubs_w_reg_datamodify
end type
type dw_master from u_d_base within ubs_w_reg_datamodify
end type
type dw_cond from u_d_help within ubs_w_reg_datamodify
end type
type p_close from u_p_close within ubs_w_reg_datamodify
end type
type gb_1 from groupbox within ubs_w_reg_datamodify
end type
end forward

global type ubs_w_reg_datamodify from w_base
integer width = 3625
integer height = 1888
event ue_close ( )
event ue_inputvalidcheck ( ref integer ai_return )
event ue_processvalidcheck ( ref integer ai_return )
event ue_process ( ref integer ai_return )
event ue_ok ( )
event type integer ue_reset ( )
event ue_save ( )
event keydown pbm_keydown
cb_clear cb_clear
p_save p_save
p_reset p_reset
p_ok p_ok
dw_master dw_master
dw_cond dw_cond
p_close p_close
gb_1 gb_1
end type
global ubs_w_reg_datamodify ubs_w_reg_datamodify

type variables
u_cust_db_app iu_cust_db_app

Int ii_error_chk

//Resize Panels by kEnn 2000-06-28
Integer		ii_WindowTop						//The virtual top of the window
Integer		ii_WindowMiddle					//The virtual middle of the window
Long			il_HiddenColor = 0				//Bar hidden color to match the window background
Dragobject	idrg_Top								//Reference to the Top control
Dragobject	idrg_Middle							//Reference to the Top Middle control
Dragobject	idrg_Bottom							//Reference to the Top Bottom control
Constant Integer	cii_BarThickness = 20	//Bar Thickness
Constant Integer	cii_WindowBorder = 20	//Window border to be used on all sides


String is_cus_status, is_hotbillflag, is_admst_status, is_amt_check, is_print_check
Dec    idc_bil_amt   
Long   il_extdays
end variables

forward prototypes
public subroutine of_refreshbars ()
public subroutine of_resizebars ()
public subroutine of_resizepanels ()
public subroutine wf_protect (string ai_gubun)
public function integer wfi_get_customerid (string as_customerid, string as_memberid)
end prototypes

event ue_close();CLOSE(THIS)
end event

event ue_inputvalidcheck;BOOLEAN	lb_check
LONG		ll_row

//ll_row = dw_detail.GetRow()

//lb_check = FB_SAVE_REQUIRED(dw_detail, ll_row)

IF lb_check = FALSE THEN
	ai_return = -1
END IF

RETURN
end event

event ue_processvalidcheck(ref integer ai_return);ai_return = 0

RETURN
end event

event ue_process(ref integer ai_return);ai_return = 0

RETURN
end event

event ue_ok();//해당 서비스에 해당하는 품목 조회
STRING	ls_where,		ls_change_list,		ls_payid,		ls_paydt,		ls_contno, ls_contractseq
LONG		ll_row,			ll_result, 	ll_hot_cnt
DATE		ld_paydt

dw_cond.AcceptText()

ls_change_list = Trim(dw_cond.object.change_list[1])
ls_payid   		= Trim(dw_cond.object.payid[1])
ls_paydt  		= STRING(dw_cond.object.paydt[1], 'yyyymmdd')
ld_paydt			= dw_cond.object.paydt[1]
ls_contno  		= Trim(dw_cond.object.contno[1])
ls_contractseq = dw_cond.object.contractseq[1]


IF ISNULL(ls_change_list) THEN ls_change_list = ""
IF ISNULL(ls_payid) THEN ls_payid = ""
IF ISNULL(ls_paydt) THEN ls_paydt = ""
IF ISNULL(ls_contno) THEN ls_contno = ""

IF ls_change_list = "" THEN
	F_MSG_INFO(200, Title, "CHANGE LIST")
	dw_cond.SetFocus()
	dw_cond.SetColumn("change_list")
	RETURN
END IF

IF ls_change_list = "2" THEN
		
	IF ls_contno = "" THEN
		F_MSG_INFO(200, Title, "Control No.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("contno")
		RETURN
	END IF
	ll_row = dw_master.Retrieve(ls_contno)	
	
elseif ls_change_list = "4" THEN
	
	

	IF ls_contractseq = "" THEN
		F_MSG_INFO(200, Title, "Contract No.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("contractseq")
		RETURN
	END IF
	
	ll_row = dw_master.Retrieve(ls_contractseq)	
	
	if ll_row > 0 then
		messagebox("확인", "중지일자를 변경할 경우 청구금액이 달라질 수 있으니, 반드시 확인하세요")
	end if
	
elseif ls_change_list = "3" THEN
	//hotcantract 없는 경우 보정하고 조회함.
	
     select  count(*)  into :ll_hot_cnt from hotreqdtl
     where to_char(PAYDT, 'yyyymm') = to_char(:ld_paydt, 'yyyymm')
     and payid = :ls_payid
     and payid not in (  select payid from hotcontract where to_char(hotdt ,'yyyymmd') = to_char(:ld_paydt, 'yyyymm')  and payid = :ls_payid);
	  
	IF ll_hot_cnt > 0 then
	     	 INSERT into hotcontract
			 select payid, contractseq, hotdt, crt_user, null , crtdt, null
			 from hotcontract_info
			 where payid = :ls_payid
				 and (seq, contractseq) in (select max(seq),contractseq from hotcontract_info where payid = :ls_payid group by payid, contractseq);
				
			commit;
	END IF
	
	
	IF ls_payid = "" THEN
		F_MSG_INFO(200, Title, "PAY ID")
		dw_cond.SetFocus()
		dw_cond.SetColumn("payid")
		RETURN
	END IF
	
	IF ls_paydt = "" THEN
		F_MSG_INFO(200, Title, "PAY DATE")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paydt")
		RETURN
	END IF	
	ll_row = dw_master.Retrieve(ls_payid, ld_paydt)

ELSE	
	IF ls_payid = "" THEN
		F_MSG_INFO(200, Title, "PAY ID")
		dw_cond.SetFocus()
		dw_cond.SetColumn("payid")
		RETURN
	END IF
	
	IF ls_paydt = "" THEN
		F_MSG_INFO(200, Title, "PAY DATE")
		dw_cond.SetFocus()
		dw_cond.SetColumn("paydt")
		RETURN
	END IF	
	ll_row = dw_master.Retrieve(ls_payid, ld_paydt)		
END IF

IF ll_row < 0 THEN
	F_MSG_INFO(2100, Title, "Retrieve()")
   RETURN
ELSEIF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
   RETURN	
END IF	

SetRedraw(FALSE)

IF ll_row >= 0 THEN
	p_save.TriggerEvent("ue_enable")
	dw_master.SetFocus()
	dw_cond.Enabled = FALSE
	p_ok.TriggerEvent("ue_disable")
END IF

SetRedraw(TRUE)
end event

event ue_reset;Constant Int LI_ERROR = -1
Int li_rc

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Or (dw_master.DeletedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return LI_ERROR//Process Cancel
End If

//초기화
p_ok.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")
dw_cond.Enabled = True

dw_master.Reset()
//dw_detail.Reset()
//dw_detail2.Reset()
dw_cond.ReSet()
dw_cond.InsertRow(0)

dw_cond.Object.change_list[1] = '1'		//초기값 세팅. 000PAY 수정 으로...
cb_clear.Visible = False						

dw_cond.SetFocus()
dw_cond.SetColumn("change_list")

Return 0



end event

event ue_save();STRING	ls_change_list, 	ls_customerid,		ls_itemcod_old,	ls_itemcod_new,	&
			ls_regcod,			ls_new_reg,			ls_payid,			ls_contno,			&
			ls_status_old,		ls_status_new
LONG		ll_row,				ll_payseq,			ll_seq
DEC{2}	ldc_payamt
INT		ii
DATE		ld_paydt

dw_master.AcceptText()

ll_row = dw_master.RowCount()

//IF ll_row <= 0 THEN RETURN

ls_change_list = dw_cond.Object.change_list[1]

IF ls_change_list = "1" THEN					//000PAY 일 경우
	FOR ii = 1 TO ll_row
		ls_payid 		= dw_master.Object.payid[ii]
		ls_customerid	= dw_master.Object.customerid[ii]		
		ld_paydt 		= DATE(dw_master.Object.paydt[ii])		
		ll_payseq		= dw_master.Object.payseq[ii]
		ls_itemcod_old = dw_master.Object.itemcod_old[ii]
		ls_itemcod_new = dw_master.Object.itemcod[ii]
		ls_regcod		= dw_master.Object.regcod[ii]
		ldc_payamt		= dw_master.Object.payamt[ii]
		
		IF IsNull(ls_itemcod_new) THEN ls_itemcod_new = ""
		
		IF ls_itemcod_old <> ls_itemcod_new THEN
			
			SELECT REGCOD INTO :ls_new_reg
			FROM   ITEMMST
			WHERE  ITEMCOD = :ls_itemcod_new;
			
			IF IsNull(ls_new_reg) THEN ls_new_reg = ""
						
			IF ls_regcod <> ls_new_reg THEN
				ROLLBACK;
				f_msg_info(100, title, "REGCOD 가 다릅니다. 처리할 수 없습니다.")
				RETURN
			END IF
			
			UPDATE DAILYPAYMENTH
			SET    ITEMCOD = :ls_itemcod_new,
					 UPDTDT  = SYSDATE,
					 UPDT_USER = :gs_user_id
			WHERE  PAYID   = :ls_payid
			AND    PAYDT   = :ld_paydt
			AND    PAYSEQ  = :ll_payseq;
			
			IF SQLCA.SQLCode <> 0 THEN
				f_msg_sql_err(Title, "Update Error(DAILYPAYMENTH)" + SQLCA.SQLErrText)
				ROLLBACK;
				RETURN
			END IF
			
			INSERT INTO DAILYPAYMENT_CHANGE
						( CHANGE_LIST,	PAYSEQ, PAYDT, PAYID, CUSTOMERID,
						  ITEMCOD_NEW, ITEMCOD_OLD, REGCOD, PAYAMT, REPAIR_WORK,
						  CRT_USER, CRTDT, UPDT_USER, UPDTDT )
		   VALUES   ( :ls_change_list, :ll_payseq, :ld_paydt, :ls_payid, :ls_customerid,
						  :ls_itemcod_new, :ls_itemcod_old, :ls_regcod, :ldc_payamt, 'Y',
						  :gs_user_id,	SYSDATE, :gs_user_id, SYSDATE);
						  
			IF SQLCA.SQLCode <> 0 THEN
				f_msg_sql_err(Title, "Insert Error(DAILYPAYMENT_CHANGE)" + SQLCA.SQLErrText)
				ROLLBACK;
				RETURN
			END IF
		END IF
	NEXT
ELSEIF ls_change_list = "2" THEN					//CONTNO 상태 수정	
	ll_seq	 	  = dw_master.Object.seq[1]
	ls_contno	  = dw_master.Object.contno[1]
	ls_status_old = dw_master.Object.status_old[1]
	ls_status_new = dw_master.Object.status[1]
	
	IF IsNull(ls_status_new) THEN ls_status_new = ""	
	
	IF ls_status_old <> ls_status_new THEN
		IF ls_status_new = 'SN100' THEN			//ENTERING GOODS 로 변경하면
			UPDATE AD_MOBILE_RENTAL
			SET    STATUS      = :ls_status_new,
					 CUSTOMERID  = NULL,
					 CONTRACTSEQ = NULL,
					 UPDT_USER   = :gs_user_id,
					 UPDTDT		 = SYSDATE
			WHERE  CONTNO = :ls_contno;
		ELSE
			UPDATE AD_MOBILE_RENTAL
			SET    STATUS      = :ls_status_new,
					 UPDT_USER   = :gs_user_id,
					 UPDTDT		 = SYSDATE
			WHERE  CONTNO = :ls_contno;			
		END IF
		
		IF SQLCA.SQLCode <> 0 THEN
			f_msg_sql_err(Title, "Update Error(AD_MOBILE_RENTAL)" + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN
		END IF
			
		INSERT INTO AD_MOBILE_RENTAL_CHG
				 ( CONTNO, STATUS_NEW, STATUS_OLD, CRT_USER,
					CRTDT,  UPDT_USER,  UPDTDT )
		VALUES ( :ls_contno,	:ls_status_new, :ls_status_old, :gs_user_id,
					SYSDATE,		:gs_user_id,    SYSDATE );
					
		IF SQLCA.SQLCode <> 0 THEN
			f_msg_sql_err(Title, "Insert Error(AD_MOBILE_RENTAL_CHG)" + SQLCA.SQLErrText)
			ROLLBACK;
			RETURN
		END IF
	END IF
	
ELSEIF ls_change_list = "4" THEN		
	
	If dw_master.Update() < 0 then
		//ROLLBACK와 동일한 기능
		iu_cust_db_app.is_caller = "ROLLBACK"
	
		iu_cust_db_app.is_title = This.Title	
		iu_cust_db_app.uf_prc_db()
		
		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
		End If
		f_msg_info(3010,This.Title,"Save")

	Else
		//COMMIT와 동일한 기능
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.is_title = This.Title
	
		iu_cust_db_app.uf_prc_db()

		If iu_cust_db_app.ii_rc = -1 Then
			dw_master.SetFocus()
		End If
		
		 dw_master.ResetUpdate()
		 dw_master.ReSet()
		 This.Trigger Event ue_ok()

	End if

	
END IF

COMMIT;
f_msg_info(3000, Title, "변경되었습니다.")

			
						
			
			
			
			
			
		



end event

public subroutine of_refreshbars ();
end subroutine

public subroutine of_resizebars ();
end subroutine

public subroutine of_resizepanels ();
end subroutine

public subroutine wf_protect (string ai_gubun);
end subroutine

public function integer wfi_get_customerid (string as_customerid, string as_memberid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기
	Date	: 2003.03.04
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
------------------------------------------------------------------------*/
STRING 	ls_customernm, 	ls_payid, 	ls_partner, 	ls_customerid, 	ls_memberid
Integer	li_sw

IF as_customerid <> "" THEN
	li_sw = 1
ELSE
	li_sw = 2
END IF

IF li_sw = 1  THEN
	SELECT  CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
			, MEMBERID
	INTO	  :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner,
			  :ls_memberid
	FROM    CUSTOMERM
	WHERE   CUSTOMERID = :as_customerid;
	 
	ls_customerid = as_customerid
ELSE
	SELECT  CUSTOMERID
			, CUSTOMERNM
			, STATUS
			, PAYID
			, PARTNER
	INTO	  :ls_customerid,
	        :ls_customernm,
		     :is_cus_status,
		     :ls_payid,
		     :ls_partner
	FROM    CUSTOMERM
	WHERE   MEMBERID = :as_memberid;
	
	ls_memberid = as_customerid
END IF

IF SQLCA.SQLCODE = 100 THEN		//Not Found
	IF li_sw = 1 THEN
   	F_MSG_USR_ERR(201, Title, "Customer ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("customerid")
	ELSE
   	F_MSG_USR_ERR(201, Title, "Member ID")
   	dw_cond.SetFocus()
   	dw_cond.SetColumn("memberid")
	END IF
   RETURN -1
END IF

SELECT HOTBILLFLAG
INTO   :is_hotbillflag
FROM   CUSTOMERM
WHERE  CUSTOMERID = :ls_payid;

IF SQLCA.SQLCODE = 100 THEN		//Not Found
   F_MSG_USR_ERR(201, Title, "고객번호(납입자번호)")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

IF IsNull(is_hotbillflag) THEN is_hotbillflag = ""
IF is_hotbillflag = 'S' THEN    //현재 Hotbilling고객이면 개통신청 못하게 한다.
   F_MSG_USR_ERR(201, Title, "즉시불처리중인고객")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   RETURN -1
END IF

dw_cond.object.customernm[1] 	= ls_customernm
dw_cond.object.customerid[1] 	= ls_customerid
dw_cond.object.memberid[1] 	= ls_memberid

RETURN 0

end function

on ubs_w_reg_datamodify.create
int iCurrent
call super::create
this.cb_clear=create cb_clear
this.p_save=create p_save
this.p_reset=create p_reset
this.p_ok=create p_ok
this.dw_master=create dw_master
this.dw_cond=create dw_cond
this.p_close=create p_close
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.cb_clear
this.Control[iCurrent+2]=this.p_save
this.Control[iCurrent+3]=this.p_reset
this.Control[iCurrent+4]=this.p_ok
this.Control[iCurrent+5]=this.dw_master
this.Control[iCurrent+6]=this.dw_cond
this.Control[iCurrent+7]=this.p_close
this.Control[iCurrent+8]=this.gb_1
end on

on ubs_w_reg_datamodify.destroy
call super::destroy
destroy(this.cb_clear)
destroy(this.p_save)
destroy(this.p_reset)
destroy(this.p_ok)
destroy(this.dw_master)
destroy(this.dw_cond)
destroy(this.p_close)
destroy(this.gb_1)
end on

event open;call super::open;//=========================================================//
// Desciption : 수납 아이템, 모바일 기기 상태를 변경       //
// Name       : ubs_w_reg_datamodify		                 //
// Contents   : 수납 아이템, 모바일 기기 상태를 변경한다   //
// Data Window: dw - ubs_dw_reg_datamodify_cnd   		     // 
//							ubs_dw_reg_datamodify_mas1				  //
// 작성일자   : 2009.07.29                                 //
// 작 성 자   : 최재혁 대리                                //
// 수정일자   :                                            //
// 수 정 자   :                                            //
//=========================================================//

STRING	ls_ref_desc

iu_cust_db_app = CREATE u_cust_db_app

// Set the Top, Bottom Controls
//idrg_Top = dw_master
//idrg_Bottom = dw_detail

//Change the back color so they cannot be seen.
//ii_WindowTop = idrg_Top.Y
//st_horizontal.BackColor = BackColor
//il_HiddenColor = BackColor

// Call the resize functions
//of_ResizeBars()
//of_ResizePanels()

dw_cond.InsertRow(0)

dw_cond.Object.change_list[1] = '1'		//초기값 세팅. 000PAY 수정 으로...

p_reset.TriggerEvent("ue_enable")
p_save.TriggerEvent("ue_disable")
end event

event close;call super::close;DESTROY iu_cust_db_app
end event

event resize;//2009-03-17 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
IF sizetype = 1 THEN RETURN

SetRedraw(FALSE)

IF newheight < (dw_master.Y + iu_cust_w_resize.ii_button_space) THEN
	dw_master.Height = 0
  
	p_save.Y		= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space	
	p_close.Y	= dw_master.Y + iu_cust_w_resize.ii_dw_button_space
ELSE
	dw_master.Height = newheight - dw_master.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space 
 
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1	
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
END IF

IF newwidth < dw_master.X  THEN
	dw_master.Width = 0
ELSE
	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
END IF

// Call the resize functions
of_ResizeBars()
of_ResizePanels()

SetRedraw(TRUE)

end event

event closequery;Int li_rc

dw_master.AcceptText()

If (dw_master.ModifiedCount() > 0) Then
	li_rc = MessageBox(This.Title, "Data is Modified.! Do you want to cancel?",&
		Question!, YesNo!)
   If li_rc <> 1 Then  Return 1 //Process Cancel
End If
end event

event key;call super::key;Choose Case key
	Case KeyEnter!
		
		 TriggerEvent("ue_ok")

End Choose

end event

type cb_clear from commandbutton within ubs_w_reg_datamodify
boolean visible = false
integer x = 2921
integer y = 56
integer width = 283
integer height = 96
integer taborder = 20
integer textsize = -9
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
string text = "CLEAR"
end type

event clicked;//해당 서비스에 해당하는 품목 조회
STRING	ls_where,		ls_change_list,		ls_payid,		ls_paydt,		ls_contno,		&
			ls_sysdate,		ls_errmsg
LONG		ll_row,			ll_result,				ll_hot_daily,	ll_return,		ll_hot_cnt, ll_hotcont_cnt
DATE		ld_paydt
LONG 		ll_daily_hotcan, ll_daily_hot
DECIMAL 		ldc_hot_amt

dw_cond.AcceptText()

ll_return = -1
ls_errmsg = space(256)

ls_change_list = Trim(dw_cond.object.change_list[1])
ls_payid   		= Trim(dw_cond.object.payid[1])
ls_paydt  		= STRING(dw_cond.object.paydt[1], 'yyyymmdd')

IF ISNULL(ls_change_list) THEN ls_change_list = ""
IF ISNULL(ls_payid) THEN ls_payid = ""
IF ISNULL(ls_paydt) THEN ls_paydt = ""

IF ls_change_list = "" THEN
	F_MSG_INFO(200, Title, "CHANGE LIST")
	dw_cond.SetFocus()
	dw_cond.SetColumn("change_list")
	RETURN -1
END IF

IF ls_payid = "" THEN
	F_MSG_INFO(200, Title, "PAY ID")
	dw_cond.SetFocus()
	dw_cond.SetColumn("payid")
	RETURN -1
END IF
	
IF ls_paydt = "" THEN
	F_MSG_INFO(200, Title, "PAY DATE")
	dw_cond.SetFocus()
	dw_cond.SetColumn("paydt")
	RETURN -1
END IF	

SELECT TO_CHAR(SYSDATE, 'YYYYMM') INTO :ls_sysdate
FROM   DUAL;

//IF ls_sysdate <> Mid(ls_paydt, 1, 6) THEN
//	F_MSG_INFO(200, Title, "당월 데이터만 Clear 할 수 있습니다.")	
//	RETURN -1
//END IF	

ls_paydt = ls_sysdate //현재월로 처리함. 이윤주과장 요청사항임





/* Clear 대상이 아닌 핫빌캔슬 건 걸러내기 start*/
//당월 핫빌 건수
SELECT COUNT(*) INTO :ll_daily_hot
FROM DAILYPAYMENT
WHERE PAYID = :ls_payid 
	AND PAYDT BETWEEN TO_DATE( substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD') AND LAST_DAY(TO_DATE(substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD'))
	AND    PGM_ID = 'HOTBILL';

//당월 핫빌취소 건수
SELECT COUNT(*) INTO :ll_daily_hotcan
FROM DAILYPAYMENT
WHERE PAYID = :ls_payid 
	AND PAYDT BETWEEN TO_DATE(substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD') AND LAST_DAY(TO_DATE(substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD'))
	AND    PGM_ID = 'HOTCAN';

//당월 핫빌 수납금액
SELECT SUM(TRAMT) INTO :ldc_hot_amt
FROM HOTREQDTL
WHERE  PAYID = :ls_payid 
    AND   PAYDT BETWEEN TO_DATE(substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD') AND LAST_DAY(TO_DATE(substr(:ls_paydt, 1, 6)||'01', 'YYYYMMDD'))
	 AND  TRCOD IN (SELECT TRCOD FROM TRCODE WHERE IN_YN = 'Y');
	 
IF ll_daily_hot > 0 and ll_daily_hotcan = 0 THEN  // 핫빌 후 취소내역이 없는경우
	F_MSG_INFO(200, Title, "당월 핫빌 자료가 존재합니다. Hotbill Cancel로 처리하세요.")
	RETURN -1
END IF	

// 핫빌 후 취소하고 다시 핫빌한 경우.. 여러번 취소후 핫빌 할 수 있기 때문에 ldc_hot_amt 금액을 체크해야 한다.
IF ll_daily_hot > 0 and ll_daily_hotcan > 0  and  ldc_hot_amt > 0 THEN    
	F_MSG_INFO(200, Title, "당월 핫빌 자료가 존재합니다. Hotbill Cancel로 처리하세요.")
	RETURN -1
END IF

/* Clear 대상이 아닌 핫빌캔슬 건 걸러내기 end */

//SELECT COUNT(*) INTO :ll_hot_cnt
//FROM   HOTREQDTL
//WHERE  PAYID = :ls_payid;

//IF ll_hot_cnt <= 0 THEN
//	F_MSG_INFO(200, Title, "Clear할 데이터가 없습니다.")
//	RETURN -1
//END IF	

SELECT COUNT(*) INTO :ll_hotcont_cnt
FROM HOTCONTRACT
WHERE PAYID = :ls_payid AND TO_CHAR(HOTDT, 'YYYYMM') = :ls_sysdate;

IF ll_hotcont_cnt <= 0 THEN
	F_MSG_INFO(200, Title, "HOTCONTRACT - Clear할 데이터가 없습니다.")
	RETURN -1
END IF		
	
//당월 핫빌인지 확인...
//SELECT COUNT(*) INTO :ll_hot_daily
//FROM   DAILYPAYMENT
//WHERE  PAYID = :ls_payid
//AND    PAYDT BETWEEN TO_DATE(:ls_sysdate||'01', 'YYYYMMDD') AND LAST_DAY(TO_DATE(:ls_sysdate||'01', 'YYYYMMDD'))
//AND    PGM_ID = 'HOTBILL';
//
//
//IF ll_hot_daily > 0 THEN
//	F_MSG_INFO(200, Title, "당월 핫빌 자료가 아니므로 Clear 할 수 없는 고객입니다")	
//	RETURN -1
//END IF

IF MessageBox('확인', ls_payid + ' 고객 핫빌 Clear 작업을 하시겠습니까?', Question!, YesNo!, 2) = 1 THEN
	SQLCA.HOTCLEAR(ls_payid, gs_user_id, ll_return, ls_errmsg)	
	
	If SQLCA.SQLCode < 0 Then		//For Programer
		MessageBox(Title+'~r~n'+"1 " +ls_errmsg, String(SQLCA.SQLCode) + '~r~n ' + SQLCA.SQLErrText)
		ROLLBACK;
	   Return -1
	ElseIf ll_return < 0 Then	//For User
		MessageBox(Title, "1 " + ls_errmsg)
		ROLLBACK;
		Return -1
	End if
	
	COMMIT;	
	
	parent.TriggerEvent("ue_ok")

	f_msg_info(3000, Title, "처리되었습니다.")	
END IF

RETURN 0


end event

type p_save from u_p_save within ubs_w_reg_datamodify
integer x = 23
integer y = 1652
end type

type p_reset from u_p_reset within ubs_w_reg_datamodify
integer x = 338
integer y = 1652
boolean originalsize = false
end type

type p_ok from u_p_ok within ubs_w_reg_datamodify
integer x = 3255
integer y = 56
end type

type dw_master from u_d_base within ubs_w_reg_datamodify
integer x = 14
integer y = 300
integer width = 3557
integer height = 1292
integer taborder = 30
string dataobject = "ubs_dw_reg_datamodify_mas1"
boolean vscrollbar = false
borderstyle borderstyle = stylebox!
end type

event clicked;IF row <= 0 THEN RETURN


if dw_cond.object.change_list[1] = '4' then //중지일자변경

	if dwo.name = 'b_del' then //삭제
	    this.deleterow(0)
	end if

end if
end event

event constructor;SetTransObject(SQLCA)
end event

event itemchanged;integer li_ret
date fr_date, to_date

this.accepttext()


if dw_cond.object.change_list[1] = '4' then
	
	fr_date = date(this.object.fromdt[row])
	to_date = date(this.object.todt[row])
	
	li_ret = fi_chk_frto_day(fr_date, to_date)
	if li_ret <> 0 then
		messagebox("확인", "유효하지 않은 일자이거나 종료일자가 시작일자보다 크지 않은지 확인하세요")
		return 2	
	end if
	
end if

end event

event itemerror;return 1
end event

type dw_cond from u_d_help within ubs_w_reg_datamodify
integer x = 46
integer y = 36
integer width = 2720
integer height = 232
integer taborder = 10
string dataobject = "ubs_dw_reg_datamodify_cnd"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
borderstyle borderstyle = stylebox!
end type

event doubleclicked;call super::doubleclicked;THIS.AcceptText()

CHOOSE CASE dwo.name
	CASE "payid"
		IF iu_cust_help.ib_data[1] THEN
			Object.payid[row]   = iu_cust_help.is_data2[1]		//고객번호
			Object.payernm[row] = iu_cust_help.is_data2[2]		//고객명			
		
		END IF
END CHOOSE

RETURN 0 
end event

event ue_init;//Help Window
THIS.idwo_help_col[1] 	= THIS.Object.payid
THIS.is_help_win[1] 		= "b5w_hlp_paymst"
THIS.is_data[1] 			= "CloseWithReturn"

THIS.SetFocus()
THIS.SetRow(1)
end event

event itemchanged;call super::itemchanged;STRING	ls_customernm, ls_sql, ls_payid
LONG		ll_cnt, ll_row
Datawindowchild ldwc_contractseq
integer li_rc

THIS.AcceptText()

CHOOSE CASE dwo.name
		
	CASE 'change_list'
		IF data = '1' THEN
			dw_master.DataObject = "ubs_dw_reg_datamodify_mas1"
			dw_master.SetTransObject(SQLCA)
			cb_clear.Visible = False			
		ELSEIF data = '2' THEN
			dw_master.DataObject = "ubs_dw_reg_datamodify_mas2"
			dw_master.SetTransObject(SQLCA)
			cb_clear.Visible = False						
		ELSEIF data = '3' THEN
			dw_master.DataObject = "ubs_dw_reg_datamodify_mas3"
			dw_master.SetTransObject(SQLCA)
			cb_clear.Visible = True
			dw_cond.object.paydt[1] = today()
		ELSEIF data = '4' THEN
			dw_master.DataObject = "ubs_dw_reg_datamodify_mas4"
			dw_master.SetTransObject(SQLCA)
			cb_clear.Visible = False
			
			ls_payid = dw_cond.object.payid[1]
			if ls_payid <> '' then
				
				li_rc = THIS.GetChild("contractseq", ldwc_contractseq)
				
					IF li_rc = -1 THEN
						f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
						RETURN 2
					END IF		
					
					
					ls_sql = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
					" FROM   CONTRACTMST A, PRICEPLANMST B " + &
					" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
					" AND    A.CUSTOMERID = '" + ls_payid + "' " +&	
					" ORDER BY A.CONTRACTSEQ ASC "
					
					ldwc_contractseq.SetSqlselect(ls_sql)
					ldwc_contractseq.SetTransObject(SQLCA)
					ll_row = ldwc_contractseq.Retrieve()
			
					IF ll_row < 0 THEN 				//디비 오류 
						f_msg_usr_err(2100, Title, "CONTRACTSEQ Retrieve()")			
						RETURN 2
					END IF
			END IF	
		END IF		
		
	CASE 'payid'

			SELECT CUSTOMERNM INTO :ls_customernm
			FROM   CUSTOMERM
			WHERE  CUSTOMERID = :data;
			
			IF SQLCA.SQLCODE <> 0 THEN
				f_msg_info(200, Title, "Record Not Found!")
				SetFocus()
				SetColumn("payid")
				Object.payid[row]		  = ""
				Object.payeynm[row] = ""				
				return 2
			END IF
			
			Object.payernm[row] = ls_customernm 
			
			
			if dw_cond.object.change_list[1] = '4' then //중지일자변경
			
				li_rc = THIS.GetChild("contractseq", ldwc_contractseq)
			
				IF li_rc = -1 THEN
					f_msg_usr_err(9000, Parent.Title, "Not a DataWindow Child")
					RETURN 2
				END IF		
				
				
				ls_sql = " SELECT A.CONTRACTSEQ, B.PRICEPLAN_DESC " + &
				" FROM   CONTRACTMST A, PRICEPLANMST B " + &
				" WHERE  A.PRICEPLAN = B.PRICEPLAN " +&
				" AND    A.CUSTOMERID = '" + data + "' " +&	
				" ORDER BY A.CONTRACTSEQ ASC "
				
				ldwc_contractseq.SetSqlselect(ls_sql)
				ldwc_contractseq.SetTransObject(SQLCA)
				ll_row = ldwc_contractseq.Retrieve()
		
				IF ll_row < 0 THEN 				//디비 오류 
					f_msg_usr_err(2100, Title, "CONTRACTSEQ Retrieve()")			
					RETURN 2
				END IF
			END if
			//
		
	CASE "contno"	
		
		IF data = '1' THEN
			SELECT COUNT(*) INTO :ll_cnt
			FROM   AD_MOBILE_RENTAL
			WHERE  CONTNO = :data;		
			
			IF ll_cnt <= 0 THEN
				THIS.Object.contno[row] = ""
				F_MSG_USR_ERR(200, Title, "Control No.")
				RETURN 2
			END IF		
			
		END IF
		
		 

END CHOOSE
end event

event constructor;Int li_i

SetTransObject(SQLCA)

iu_cust_help = create u_cust_a_msg

Trigger Event ue_init()  // append by csh

//*****DataWindow의 Help Row의 색깔 및 Pointer 처리
ii_help_col_no = UpperBound(is_help_win)
For li_i = 1 To ii_help_col_no
//	idwo_help_col[li_i].Color = il_help_col_color
	idwo_help_col[li_i].Pointer = is_help_cur
Next

end event

type p_close from u_p_close within ubs_w_reg_datamodify
integer x = 654
integer y = 1652
boolean originalsize = false
end type

type gb_1 from groupbox within ubs_w_reg_datamodify
integer x = 14
integer y = 8
integer width = 3557
integer height = 280
integer taborder = 20
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

