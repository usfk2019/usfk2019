$PBExportHeader$ubs_w_reg_ppcupload.srw
$PBExportComments$[jhchoi] PPC카드 충전 UPLOAD - 2010.05.18
forward
global type ubs_w_reg_ppcupload from w_a_reg_m_m
end type
type dw_file from datawindow within ubs_w_reg_ppcupload
end type
type dw_temp from datawindow within ubs_w_reg_ppcupload
end type
type gb_1 from groupbox within ubs_w_reg_ppcupload
end type
type gb_3 from groupbox within ubs_w_reg_ppcupload
end type
end forward

global type ubs_w_reg_ppcupload from w_a_reg_m_m
integer width = 2679
integer height = 1908
dw_file dw_file
dw_temp dw_temp
gb_1 gb_1
gb_3 gb_3
end type
global ubs_w_reg_ppcupload ubs_w_reg_ppcupload

type variables
String 	is_serial_fr, 		is_contno_fr, &
			is_serial_to, 		is_contno_to,		is_file
Long		il_serial_len,	il_contno_len
DEC		il_serial_fr, 	il_serial_to, il_contno_fr, il_contno_to
end variables

forward prototypes
public subroutine of_resizepanels ()
public subroutine wf_change_no (string wfs_fr, string wfs_to, integer wfi_sw)
public function integer wf_maccheck (string as_macaddr)
public function integer wf_protect (string as_gubun)
end prototypes

public subroutine of_resizepanels ();dw_detail.Width = 1989
end subroutine

public subroutine wf_change_no (string wfs_fr, string wfs_to, integer wfi_sw);Long		ll_no
String 	ls_no_fr, 	ls_no_to, 	ls_val
Integer 	li_pos_fr, 	li_pos_to, &
			li_pos,		jj,  			li_asc, li_len

ls_no_fr 	= wfs_fr
ls_no_to 	= wfs_to

ll_no 	= 0

//===============>> FROM
li_pos 	= 0
li_len 	= LenA(ls_no_fr)

FOR jj =  li_len	 to 1 	step -1
	li_asc =  AscA(MidA(ls_no_fr, jj, 1))
	IF li_asc >= 48 AND li_asc <= 57 then
	ELSE
		li_pos = jj
		exit
	END IF
NEXT

IF li_pos > 0 AND li_pos < li_len then 
	li_pos_fr =  li_pos
ELSEIF li_pos = li_len THEN
	li_pos_fr = -1
ELSE
	li_pos_fr = 0
END IF

//==========================To
li_pos 	= 0
li_len 	= LenA(ls_no_to)

FOR jj =  li_len	 to 1 	step -1
	li_asc =  AscA(MidA(ls_no_to, jj, 1))
	IF li_asc >= 48 AND li_asc <= 57 then
	ELSE
		li_pos = jj
		exit
	END IF
NEXT

IF li_pos > 0 AND li_pos < li_len then 
	li_pos_to =  li_pos
ELSEIF li_pos = li_len THEN
	li_pos_to = -1
ELSE
	li_pos_to = 0
END IF

choose case wfi_sw
	case 1 // serial
		il_serial_len = li_len - li_pos_fr
		IF li_pos_fr <> -1 then
			is_serial_fr =  LeftA(ls_no_fr, li_pos_fr)
			il_serial_fr = DEC(MidA(ls_no_fr, li_pos_fr + 1, LenA(ls_no_fr) - li_pos_fr))
		END IF

		IF li_pos_to <> -1 then
			is_serial_to =  LeftA(ls_no_to, li_pos_to)
			il_serial_to = DEC(MidA(ls_no_to, li_pos_to + 1, LenA(ls_no_to) - li_pos_to))
		END IF
	case else //contno
		il_contno_len = li_len - li_pos_fr
		IF li_pos_fr <> -1 then
			is_contno_fr =  LeftA(ls_no_fr, li_pos_fr)
			il_contno_fr = Long(MidA(ls_no_fr, li_pos_fr + 1, LenA(ls_no_fr) - li_pos_fr))
		END IF

		IF li_pos_to <> -1 then
			is_contno_to =  LeftA(ls_no_to, li_pos_to)
			il_contno_to = Long(MidA(ls_no_to, li_pos_to + 1, LenA(ls_no_to) - li_pos_to))
		END IF
end choose

Return 
end subroutine

public function integer wf_maccheck (string as_macaddr);STRING	ls_temp
LONG		ll_length, ll_ascii
INT		ii

ll_length = LenA(as_macaddr)

IF ll_length <> 14 THEN
	Return -1	
END IF

FOR ii = 1 TO ll_length
	ls_temp = MidA(as_macaddr, ii, 1)
	
	ll_ascii = AscA(ls_temp)
	
	IF ll_ascii = 46 OR (ll_ascii >= 48 AND ll_ascii <= 57) OR (ll_ascii >= 97 AND ll_ascii <= 102) OR (ll_ascii >= 65 AND ll_ascii <= 70) THEN
		//숫자 0~9, 대문자 A~F
	ELSE
		RETURN -1
		EXIT
	END IF
NEXT

return 0
end function

public function integer wf_protect (string as_gubun);STRING	ls_modelno,		ls_equiptype
dw_master.AcceptText()

IF as_gubun = "C"	THEN				//CLEAR
	dw_detail.Object.serialno.Color = RGB(255, 255, 255)
	dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.serialno.Protect = 0	
	dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
	dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.dacom_mng_no.Protect = 0	
	dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.mac_addr.Protect = 0	
	dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
	dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr2.Protect = 0		
	dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
	dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.sap_no.Protect = 0
ELSEIF as_gubun = "1" THEN			//판매장비일 때
	ls_modelno = dw_master.Object.modelno[1]
	
	SELECT EQUIPTYPE INTO :ls_equiptype
	FROM   EQUIPMODEL
	WHERE  MODELNO = :ls_modelno;
	
//2009.08.14 이윤주 대리 요청. 판매장비는 무조건 시리얼과 맥1만 있으면 된다.	
//	IF ls_equiptype = "WF02" THEN
//		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
//		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.serialno.Protect = 1	
//		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
//		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.dacom_mng_no.Protect = 0			
//		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.mac_addr.Protect = 0			
//		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
//		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr2.Protect = 0		
//		dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.sap_no.Protect = 1				
//	ELSE
//		dw_detail.Object.serialno.Color = RGB(255, 255, 255)
//		dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)
//		dw_detail.Object.serialno.Protect = 0	
//		dw_detail.Object.dacom_mng_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.dacom_mng_no.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.dacom_mng_no.Protect = 1			
//		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
//		dw_detail.Object.mac_addr.Protect = 0			
//		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
//		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
//		dw_detail.Object.mac_addr2.Protect = 0		
//		dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
//		dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
//		dw_detail.Object.sap_no.Protect = 1						
//	END IF
	
	dw_detail.Object.serialno.Color = RGB(255, 255, 255)
	dw_detail.Object.serialno.Background.Color = RGB(107, 146, 140)
	dw_detail.Object.serialno.Protect = 0	
	dw_detail.Object.dacom_mng_no.Color = RGB(0, 0, 0)
	dw_detail.Object.dacom_mng_no.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.dacom_mng_no.Protect = 1			
	dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
	dw_detail.Object.mac_addr.Protect = 0			
	dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
	dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
	dw_detail.Object.mac_addr2.Protect = 0		
	dw_detail.Object.sap_no.Color = RGB(0, 0, 0)
	dw_detail.Object.sap_no.Background.Color = RGB(255, 255, 255)	
	dw_detail.Object.sap_no.Protect = 1						

ELSEIF as_gubun = "0" THEN					//임대장비
	
	ls_modelno = dw_master.Object.modelno[1]
	
	SELECT EQUIPTYPE INTO :ls_equiptype
	FROM   EQUIPMODEL
	WHERE  MODELNO = :ls_modelno;
	
	IF ls_equiptype = "VO01" THEN
		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
		dw_detail.Object.serialno.Protect = 0	
		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.dacom_mng_no.Protect = 0			
		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr.Protect = 0			
		dw_detail.Object.mac_addr2.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr2.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr2.Protect = 0		
		dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
		dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.sap_no.Protect = 0			
	ELSE
		dw_detail.Object.serialno.Color = RGB(0, 0, 0)
		dw_detail.Object.serialno.Background.Color = RGB(255, 255, 255)	
		dw_detail.Object.serialno.Protect = 0	
		dw_detail.Object.dacom_mng_no.Color = RGB(255, 255, 255)
		dw_detail.Object.dacom_mng_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.dacom_mng_no.Protect = 0			
		dw_detail.Object.mac_addr.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.mac_addr.Protect = 0			
		dw_detail.Object.mac_addr2.Color = RGB(0, 0, 0)
		dw_detail.Object.mac_addr2.Background.Color = RGB(255, 255, 255)
		dw_detail.Object.mac_addr2.Protect = 0		
		dw_detail.Object.sap_no.Color = RGB(255, 255, 255)
		dw_detail.Object.sap_no.Background.Color = RGB(107, 146, 140)		
		dw_detail.Object.sap_no.Protect = 0
	END IF
END IF

return 0
end function

on ubs_w_reg_ppcupload.create
int iCurrent
call super::create
this.dw_file=create dw_file
this.dw_temp=create dw_temp
this.gb_1=create gb_1
this.gb_3=create gb_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_file
this.Control[iCurrent+2]=this.dw_temp
this.Control[iCurrent+3]=this.gb_1
this.Control[iCurrent+4]=this.gb_3
end on

on ubs_w_reg_ppcupload.destroy
call super::destroy
destroy(this.dw_file)
destroy(this.dw_temp)
destroy(this.gb_1)
destroy(this.gb_3)
end on

event ue_ok;LONG		ll_row

ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_info(2100, Title, "Retrieve()")
   Return
End If

p_save.TriggerEvent("ue_enable")
p_reset.TriggerEvent("ue_enable")

end event

event resize;//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
	gb_1.Height = 0
  
	p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_close.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space	
Else
	
	dw_detail.Height	= newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space
	
	p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space_1 
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space_1
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	p_close.Y	= newheight - iu_cust_w_resize.ii_button_space_1
	
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width   = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

//If newwidth < dw_master.X  Then
//	dw_master.Width = 0
//Else
//	dw_master.Width = newwidth - dw_master.X - iu_cust_w_resize.ii_dw_button_space
//End If

// Call the resize functions
of_ResizeBars()
//of_ResizePanels()

SetRedraw(True)

end event

event ue_reset;call super::ue_reset;p_ok.TriggerEvent("ue_enable")

//p_insert.TriggerEvent("ue_disable")
//p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")

dw_detail.Enabled = False
dw_detail.reset()

//dw_master.Enabled = True
//dw_master.reset()
//dw_master.Retrieve()

dw_temp.reset()
dw_file.reset()
dw_file.insertRow(1)

RETURN 0

end event

event ue_extra_save;Long		ll_row,			ll_record_cnt,			ii,						ll_post_cnt,			ll_amount
STRING	ls_work_type,	ls_cardno,				ls_customerid,			ls_usercode,			ls_crt_user
STRING   ls_msgcode,		ls_remark
DEC		ldc_saleamt

ll_row = dw_detail.RowCount()

//데이터 있으면 삭제하자
SELECT COUNT(*) INTO :ll_record_cnt
FROM   SSRTPPCIF_DUMY;

IF ll_record_cnt > 0 THEN
	//데이터 삭제
	DELETE FROM SSRTPPCIF_DUMY;
	
	IF SQLCA.SQLCODE <> 0 THEN
		f_msg_usr_err(201, Title, "기존 데이터 삭제에 실패했습니다." + SQLCA.SQLErrText)		
		ROLLBACK;
		RETURN -1
	END IF
END IF	

//데이터 입력...
FOR ii = 1 TO ll_row
	ls_work_type	= dw_detail.Object.work_type[ii]
	ls_cardno		= dw_detail.Object.cardno[ii]
	ll_amount		= dw_detail.Object.amount[ii]
	ls_usercode		= dw_detail.Object.usercode[ii]
	ls_crt_user		= dw_detail.Object.crt_user[ii]
	ls_msgcode		= dw_detail.Object.msgcode[ii]
	ls_remark		= dw_detail.Object.remark[ii]
	ls_customerid  = dw_detail.Object.customerid[ii]
	
	INSERT INTO SSRTPPCIF_DUMY 
		( SEQNO,							WORK_TYPE,					CARDNO,
		  AMOUNT,						USERCODE,					CRT_USER,
		  MSGCODE,						REMARK,						CUSTOMERID,
		  CRTDT )
	VALUES
		( SEQ_SSRTPPCIF.NEXTVAL,	:ls_work_type,				:ls_cardno,
		  :ll_amount,					:ls_usercode,				:ls_crt_user,
		  :ls_msgcode,					:ls_remark,					:ls_customerid,
		  SYSDATE );
	
	IF SQLCA.SQLCODE <> 0 THEN
		f_msg_usr_err(201, Title, "저장에 실패했습니다.(SSRTPPCIF_DUMY)" + SQLCA.SQLErrText)		
		ROLLBACK;
		RETURN -1
	END IF
	
	dw_detail.SetItemStatus(ii, 0, Primary!, NotModified!)
	
NEXT

//넘기는 로직!
SELECT COUNT(*) INTO :ll_post_cnt
FROM	 SSRTPPCIF_DUMY;

IF ll_post_cnt > 0 THEN
	
	INSERT INTO SSRTPPCIF
	SELECT * FROM SSRTPPCIF_DUMY;
	
	IF SQLCA.SQLCODE <> 0 THEN
		f_msg_usr_err(201, Title, "저장에 실패했습니다.(SSRTPPCIF)" + SQLCA.SQLErrText)		
		ROLLBACK;
		RETURN -1
	END IF
	
END IF

COMMIT;

RETURN 0
end event

event ue_save;Constant Int LI_ERROR = -1

Long result

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End if

If This.Trigger Event ue_extra_save() < 0 Then
	dw_detail.SetFocus()
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
ELSE	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	f_msg_info(3000,This.Title,"Save")
End if

//저장완료
p_save.TriggerEvent("ue_disable")
dw_file.Enabled = False
dw_detail.Enabled = False
This.TriggerEvent("ue_reset")

//ii_error_chk = 0
Return 0

end event

event ue_insert;//Constant Int LI_ERROR = -1
//Long ll_row
//
//ll_row = dw_detail.InsertRow(dw_detail.rowcount()+1)
//
////장비번호
////새 장비번호 추출
//Long ll_equipseq			//새 장비번호
//
//	SELECT SEQ_EQUIPSEQ.nextval
//	INTO :ll_equipseq
//	FROM dual;
//
//dw_detail.Object.equipseq[ll_row]	= ll_equipseq							//장비번호	
//dw_detail.Object.contno[ll_row]		= STRING(ll_equipseq)				//CONTNO
//		
//dw_detail.Object.num[ll_row] = ll_row
//
//dw_detail.ScrollToRow(ll_row)
//dw_detail.SetRow(ll_row)
//dw_detail.SetFocus()
//
//dw_master.Object.iqty[1] = ll_row

Return 0

end event

event ue_delete;Return 0
end event

type dw_cond from w_a_reg_m_m`dw_cond within ubs_w_reg_ppcupload
boolean visible = false
integer x = 3104
integer y = 536
integer width = 101
integer height = 48
end type

type p_ok from w_a_reg_m_m`p_ok within ubs_w_reg_ppcupload
integer x = 2309
boolean originalsize = false
end type

type p_close from w_a_reg_m_m`p_close within ubs_w_reg_ppcupload
integer x = 626
integer y = 1652
end type

type gb_cond from w_a_reg_m_m`gb_cond within ubs_w_reg_ppcupload
boolean visible = false
integer x = 3067
integer y = 488
integer width = 174
integer height = 120
end type

type dw_master from w_a_reg_m_m`dw_master within ubs_w_reg_ppcupload
event ue_cal ( )
boolean visible = false
integer y = 88
integer width = 795
integer height = 156
boolean enabled = false
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_master::clicked;//상속막음
end event

event dw_master::retrieveend;//
end event

type dw_detail from w_a_reg_m_m`dw_detail within ubs_w_reg_ppcupload
integer x = 23
integer y = 352
integer width = 2587
integer height = 1236
string dataobject = "ubs_dw_reg_ppcupload_mas"
end type

event dw_detail::constructor;call super::constructor;This.SetRowFocusIndicator(off!)
end event

event dw_detail::itemerror;call super::itemerror;RETURN 1
end event

type p_insert from w_a_reg_m_m`p_insert within ubs_w_reg_ppcupload
boolean visible = false
integer x = 1659
end type

type p_delete from w_a_reg_m_m`p_delete within ubs_w_reg_ppcupload
boolean visible = false
integer x = 1957
end type

type p_save from w_a_reg_m_m`p_save within ubs_w_reg_ppcupload
integer x = 27
integer y = 1652
end type

type p_reset from w_a_reg_m_m`p_reset within ubs_w_reg_ppcupload
integer x = 329
integer y = 1652
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within ubs_w_reg_ppcupload
integer y = 316
end type

type dw_file from datawindow within ubs_w_reg_ppcupload
integer x = 32
integer y = 48
integer width = 1106
integer height = 252
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_ppcupload_file"
boolean border = false
boolean livescroll = true
end type

event buttonclicked;String 	ls_fileName, 		pathname,			filename,			ls_save_file
String	ls_worktype,		ls_cardno,			ls_customerid,		ls_usercode,	&
			ls_crt_user,		ls_msgcode,			ls_remark
Long		ll_row,				ll_amount,			ll_xls,				ll_return
Long		ll_iqty,				ll_iqty_temp,		ii
Int		value,				li_rtn

CHOOSE CASE	dwo.Name
	CASE "search_xls"			//엑셀 파일 찾기
		value = GetFileOpenName("Select File", pathName, fileName, "All Files (*.*),*.*", 'Excel Files (*.xls), *.xls')		
		
		IF value = 1 THEN
			This.Object.filename[1] = pathName
		END IF
		
		OleObject oleExcel 
		
		oleExcel = Create OleObject 
		li_rtn = oleExcel.connecttonewobject("excel.application") 
		
		IF value = 1 THEN
			IF li_rtn = 0 THEN
				oleExcel.WorkBooks.Open(pathName) 
			ELSE
				Messagebox("!", "실패") 
				Destroy oleExcel 
				Return -1
			END IF
		ELSE
			Destroy oleExcel 
			Return -1
		END IF
		
		oleExcel.Application.Visible = False 
		
		ll_xls = PosA(pathName, 'xls')
		ls_save_file = MidA(pathName, 1, ll_xls -2) + '.txt'
		is_file = ls_save_file

		oleExcel.application.workbooks(1).SaveAs(ls_save_file, -4158) 
		oleExcel.application.workbooks(1).Saved = True 
		oleExcel.Application.Quit 
		oleExcel.DisConnectObject() 
		Destroy oleExcel
		
	CASE "xls_load"		//파일처리

		IF isNull(is_file) THEN is_file = ""
				
		IF is_file = "" THEN
			f_msg_info(200, This.Title, "파일명")
			This.SetFocus()
			RETURN 0
		END IF
		
		ll_return = dw_temp.ImportFile(is_file)
		
		If ll_return < 0 THEN
			f_msg_usr_err(200, Title, "파일열기 실패")
			this.setFocus()
			RETURN 0
		End If		

		ll_iqty 		 = dw_detail.rowCount()
		ll_iqty_temp = dw_temp.rowCount()	
		
		FOR ii = 1 TO ll_iqty_temp
			ls_worktype		= dw_temp.Object.work_type[ii]
			ls_cardno		= dw_temp.Object.cardno[ii]
			ll_amount		= dw_temp.Object.amount[ii]
			ls_usercode		= dw_temp.Object.usercode[ii]			
			ls_crt_user		= dw_temp.Object.crt_user[ii]			
			ls_msgcode		= dw_temp.Object.msgcode[ii]
			ls_remark		= dw_temp.Object.remark[ii]
			ls_customerid	= dw_temp.Object.customerid[ii]
				
			ll_row = dw_detail.InsertRow(dw_detail.Rowcount() + 1)
			
			dw_detail.Object.work_type[ll_row]	= ls_worktype
			dw_detail.Object.cardno[ll_row]		= ls_cardno
			dw_detail.Object.amount[ll_row]		= ll_amount
			dw_detail.Object.usercode[ll_row]	= ls_usercode			
			dw_detail.Object.crt_user[ll_row]	= ls_crt_user
			dw_detail.Object.msgcode[ll_row]		= ls_msgcode
			dw_detail.Object.remark[ll_row]		= ls_remark			
			dw_detail.Object.customerid[ll_row]	= ls_customerid
		NEXT
		
		//마지막 row로 간다.
		dw_detail.ScrollToRow(ll_row)
		dw_detail.SetRow(ll_row)
		dw_detail.SetFocus()		
		
		p_save.TriggerEvent("ue_enable")
		p_reset.TriggerEvent("ue_enable")
		dw_detail.Enabled = True
		
						
END CHOOSE
end event

event constructor;InsertRow(0)
end event

type dw_temp from datawindow within ubs_w_reg_ppcupload
boolean visible = false
integer x = 1733
integer y = 1136
integer width = 832
integer height = 432
integer taborder = 40
boolean bringtotop = true
string title = "none"
string dataobject = "ubs_dw_reg_ppcupload_temp"
boolean livescroll = true
end type

event constructor;	SetTransObject(SQLCA)
end event

type gb_1 from groupbox within ubs_w_reg_ppcupload
boolean visible = false
integer x = 18
integer y = 32
integer width = 837
integer height = 276
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
boolean enabled = false
borderstyle borderstyle = stylelowered!
end type

type gb_3 from groupbox within ubs_w_reg_ppcupload
integer x = 23
integer y = 32
integer width = 1125
integer height = 276
integer taborder = 30
integer textsize = -2
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

