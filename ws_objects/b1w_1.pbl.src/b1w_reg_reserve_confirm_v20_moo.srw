$PBExportHeader$b1w_reg_reserve_confirm_v20_moo.srw
$PBExportComments$[kem] 서비스 가입예약확정처리 v20 - moohan
forward
global type b1w_reg_reserve_confirm_v20_moo from w_a_reg_m
end type
type bt_detail from commandbutton within b1w_reg_reserve_confirm_v20_moo
end type
type bt_customer from commandbutton within b1w_reg_reserve_confirm_v20_moo
end type
type bt_active from commandbutton within b1w_reg_reserve_confirm_v20_moo
end type
type gb_1 from groupbox within b1w_reg_reserve_confirm_v20_moo
end type
end forward

global type b1w_reg_reserve_confirm_v20_moo from w_a_reg_m
integer width = 3355
bt_detail bt_detail
bt_customer bt_customer
bt_active bt_active
gb_1 gb_1
end type
global b1w_reg_reserve_confirm_v20_moo b1w_reg_reserve_confirm_v20_moo

type variables
String is_status[], is_st
Long   il_seq
end variables

on b1w_reg_reserve_confirm_v20_moo.create
int iCurrent
call super::create
this.bt_detail=create bt_detail
this.bt_customer=create bt_customer
this.bt_active=create bt_active
this.gb_1=create gb_1
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.bt_detail
this.Control[iCurrent+2]=this.bt_customer
this.Control[iCurrent+3]=this.bt_active
this.Control[iCurrent+4]=this.gb_1
end on

on b1w_reg_reserve_confirm_v20_moo.destroy
call super::destroy
destroy(this.bt_detail)
destroy(this.bt_customer)
destroy(this.bt_active)
destroy(this.gb_1)
end on

event open;call super::open;String ls_ref_desc, ls_temp, ls_filter
Long   ll_row
DataWindowChild ldc

//가입자예약신청상태:가입예약;고객확정;계약확정  000;100;200
ls_ref_desc = ""
ls_temp = fs_get_control("B0", "P270", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_status[]) 


ll_row = dw_cond.GetChild("status", ldc)
If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
ls_filter = " code in ('" + is_status[1] + "','" + is_status[2] + "') "
ldc.SetFilter(ls_filter)			//Filter정함
ldc.Filter()
ldc.SetTransObject(SQLCA)
ll_row =ldc.Retrieve()

Return 0
end event

event ue_ok();call super::ue_ok;String	ls_where, ls_yyyymmdd_fr, ls_yyyymmdd_to, ls_status, ls_validkey, ls_customernm, &
         ls_ssno, ls_cregno
Long		ll_row

ls_yyyymmdd_fr = string(dw_cond.object.yyyymmdd_fr[1], 'yyyymmdd')
ls_yyyymmdd_to = string(dw_cond.object.yyyymmdd_to[1], 'yyyymmdd')	
ls_status      = fs_snvl(dw_cond.object.status[1]    , '')
ls_validkey    = fs_snvl(dw_cond.object.validkey[1]  , '')
ls_customernm  = fs_snvl(dw_cond.object.customernm[1], '')
ls_ssno        = fs_snvl(dw_cond.object.ssno[1]      , '')
ls_cregno      = fs_snvl(dw_cond.object.cregno[1]    , '')

ls_where = ""
IF ls_yyyymmdd_fr <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(reservedt,'YYYYMMDD') >= '" + ls_yyyymmdd_fr + "'"
END IF

IF ls_yyyymmdd_to <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "to_char(reservedt,'YYYYMMDD') >= '" + ls_yyyymmdd_to + "'"
END IF

IF ls_status <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "status = '" + ls_status + "'"
Else
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "status in ('" + is_status[1] + "', '" +  is_status[2] + "')"
END IF

IF ls_validkey <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "validkey like '" + ls_validkey + "%'"
END IF

IF ls_customernm <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "customernm like '" + ls_customernm + "%'"
END IF

IF ls_ssno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "ssno = '" + ls_ssno + "'"
END IF

IF ls_cregno <> "" THEN
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "cregno = '" + ls_cregno + "'"
END IF

dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

IF ll_row < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_row = 0 THEN
	f_msg_info(1000, Title, "")
End If

p_delete.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_enable")   		
dw_cond.Enabled = False	

dw_cond.SetFocus()
end event

event resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	dw_detail.Height = 0
   p_insert.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_delete.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_save.Y		= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	p_reset.Y	= dw_detail.Y + iu_cust_w_resize.ii_dw_button_space
	
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space - 15
   p_insert.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_delete.Y	= newheight - iu_cust_w_resize.ii_button_space
	p_save.Y		= newheight - iu_cust_w_resize.ii_button_space
	p_reset.Y	= newheight - iu_cust_w_resize.ii_button_space
	
End If
If newheight < (gb_1.Y + iu_cust_w_resize.ii_button_space) Then
	gb_1.Height = 0
Else
	gb_1.Height = newheight - gb_1.Y - iu_cust_w_resize.ii_button_space - iu_cust_w_resize.ii_dw_button_space + 5
End IF

If newwidth < dw_detail.X  Then
	
	dw_detail.Width = 0
	bt_detail.x  	= dw_detail.x + iu_cust_w_resize.ii_dw_button_space
	bt_customer.x	= dw_detail.x + iu_cust_w_resize.ii_dw_button_space
	bt_active.x	   = dw_detail.x + iu_cust_w_resize.ii_dw_button_space
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space - 15
	bt_detail.x	    = newwidth - iu_cust_w_resize.ii_button_space   - 314 - bt_customer.Width - bt_active.Width
	bt_customer.x	 = newwidth - iu_cust_w_resize.ii_button_space   - 250 - bt_customer.Width
	bt_active.x	    = newwidth - iu_cust_w_resize.ii_button_space   - 250 
End If

If newwidth < gb_1.X  Then
	gb_1.Width = 0
Else
	gb_1.Width = newwidth - gb_1.X - iu_cust_w_resize.ii_dw_button_space + 5
End If

SetRedraw(True)

end event

type dw_cond from w_a_reg_m`dw_cond within b1w_reg_reserve_confirm_v20_moo
integer y = 60
integer width = 2491
integer height = 252
string dataobject = "b1dw_cnd_reserve_confirm_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m`p_ok within b1w_reg_reserve_confirm_v20_moo
integer x = 2693
end type

type p_close from w_a_reg_m`p_close within b1w_reg_reserve_confirm_v20_moo
integer x = 2999
end type

type gb_cond from w_a_reg_m`gb_cond within b1w_reg_reserve_confirm_v20_moo
integer width = 2546
integer height = 328
end type

type p_delete from w_a_reg_m`p_delete within b1w_reg_reserve_confirm_v20_moo
end type

type p_insert from w_a_reg_m`p_insert within b1w_reg_reserve_confirm_v20_moo
end type

type p_save from w_a_reg_m`p_save within b1w_reg_reserve_confirm_v20_moo
end type

type dw_detail from w_a_reg_m`dw_detail within b1w_reg_reserve_confirm_v20_moo
integer x = 50
integer y = 476
integer width = 3227
integer height = 1064
string dataobject = "b1dw_reg_cnd_reserve_confirm_v20"
end type

event dw_detail::constructor;call super::constructor;SetRowFocusIndicator(off!)
end event

event dw_detail::rowfocuschanged;call super::rowfocuschanged;SelectRow(0, False)
SelectRow(currentrow, True)

If currentrow <> 0 Then
	is_st = dw_detail.Object.status[currentrow]
End IF
end event

event dw_detail::retrieveend;call super::retrieveend;p_delete.TriggerEvent("ue_disable")
p_insert.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
end event

event dw_detail::clicked;call super::clicked;IF row <= 0 Then return
is_st = dw_detail.Object.status[row]
end event

type p_reset from w_a_reg_m`p_reset within b1w_reg_reserve_confirm_v20_moo
end type

type bt_detail from commandbutton within b1w_reg_reserve_confirm_v20_moo
integer x = 1998
integer y = 364
integer width = 466
integer height = 100
integer taborder = 21
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "예약정보상세"
end type

event clicked;Long ll_preseq, ll_row

If dw_detail.rowcount() <= 0 Then Return -1

ll_preseq = dw_detail.object.preseq[dw_detail.GetRow()]

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "서비스가입예약확정처리"
iu_cust_msg.is_grp_name = "예약정보상세"
iu_cust_msg.il_data[1] = ll_preseq
iu_cust_msg.is_data[1] = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.idw_data[1] = dw_detail

//Open
OpenWithParm(b1w_reg_reserve_confirm_detail_popup_v20, iu_cust_msg)  //청구 윈도우 연다.
//처리후에 ok버튼 타게 해야함..
trigger event ue_ok()

Return 0 
end event

type bt_customer from commandbutton within b1w_reg_reserve_confirm_v20_moo
integer x = 2464
integer y = 364
integer width = 402
integer height = 100
integer taborder = 31
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "고객확정"
end type

event clicked;Integer li_rc
Long    ll_row
String  ls_ctype2, ls_ssno = '', ls_customerid, ls_cregno = ''
Boolean lb_check1, lb_check2

If dw_detail.rowcount() <= 0 Then Return -1

If is_status[1] <> is_st Then 
	f_msg_info(9000, Title, "가입예약상태의 고객만 고객확정이 가능합니다.")
	Return -1
End If

ll_row    = dw_detail.GetRow()
ls_ctype2 = dw_detail.Object.ctype2[ll_row]
il_seq    = dw_detail.object.preseq[ll_row]

//개인
b1fb_check_control("B0", "P111", "", ls_ctype2, lb_check1)
If lb_check1 Then
	ls_ssno = dw_detail.Object.ssno[ll_row]
	
	SELECT CUSTOMERID
	  INTO :ls_customerid
	  FROM CUSTOMERM
	 WHERE SSNO   = :ls_ssno
	   AND ROWNUM = 1        ;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Select Error(CUSTOMERM check CUSTOMERID)")
		Return -1
	End If	
End If

//법인
b1fb_check_control("B0", "P110", "", ls_ctype2, lb_check2)
If lb_check1 Then
	ls_cregno = dw_detail.Object.cregno[ll_row]
	
	SELECT CUSTOMERID
	  INTO :ls_customerid
	  FROM CUSTOMERM
	 WHERE cregno = :ls_cregno   
	   AND ROWNUM = 1         ;
	If SQLCA.SQLCode < 0 Then
		f_msg_sql_err(title, " Select Error(CUSTOMERM check CUSTOMERID)")
		Return -1
	End If	
End If

If IsNull(ls_customerid) Then ls_customerid = ''

//기존고객확정처리
If ls_customerid <> '' Then
	iu_cust_msg = Create u_cust_a_msg
	iu_cust_msg.is_pgm_name = "서비스가입예약확정처리"
	iu_cust_msg.is_grp_name = "고객확정처리"
	iu_cust_msg.is_data[1] = ls_ssno
	iu_cust_msg.is_data[2] = ls_cregno
	iu_cust_msg.is_data[3] = gs_pgm_id[gi_open_win_no]	//Pgm_id
	iu_cust_msg.il_data[1] = il_seq
	iu_cust_msg.idw_data[1] = dw_detail
	
	//Open
	OpenWithParm(b1w_reg_reserve_confirm_cust_popup_v20, iu_cust_msg)  
	
//신규고객확정처리	
Else
	//Save Check
	b1u_dbmgr1_v20 lu_check
	lu_check = Create b1u_dbmgr1_v20
	lu_check.is_caller = "b1w_reg_reserve_confirm_cust_popup_v20%ue_ok"
	lu_check.is_title = Title
	lu_check.il_data[1] = il_seq                    //preseq
	lu_check.is_data[1] = gs_pgm_id[gi_open_win_no]
	lu_check.is_data[2] = gs_user_id
	
	lu_check.uf_prc_db_04()
	li_rc = lu_check.ii_rc
	
	If li_rc = -1  Then
		Rollback;
		Destroy lu_check
		f_msg_info(9000, Title, "저장실패")	
		Return 
	Else
		commit;
		f_msg_info(9000, Title, "저장성공")	
	End If
	
	Destroy lu_check
	
End If


trigger event ue_ok()
//처리후에 ok버튼 타게 해야함..


end event

type bt_active from commandbutton within b1w_reg_reserve_confirm_v20_moo
integer x = 2866
integer y = 364
integer width = 402
integer height = 100
integer taborder = 31
boolean bringtotop = true
integer textsize = -9
integer weight = 400
fontcharset fontcharset = hangeul!
fontpitch fontpitch = fixed!
fontfamily fontfamily = modern!
string facename = "굴림체"
string text = "개통확정"
end type

event clicked;String ls_svccod, ls_priceplan, ls_validkey_type, ls_customerid, ls_svctype, &
       ls_svctype_1, ls_ref_desc, ls_svctype_cu, ls_validkey, ls_partner
Long   ll_row, ll_seq
If dw_detail.rowcount() <= 0 Then Return -1

If is_status[2] <> is_st Then 
	f_msg_info(9000, Title, "고객확정상태의 고객만 개통확정이 가능합니다.")
	Return -1
End If

ll_row           = dw_detail.Getrow()
ls_svccod        = dw_detail.Object.svccod[ll_row]
ls_priceplan     = dw_detail.Object.priceplan[ll_row]
ls_validkey_type = dw_detail.Object.validkey_type[ll_row]
ls_customerid    = fs_snvl(dw_detail.Object.customerid[ll_row], '')
ls_validkey      = dw_detail.Object.validkey[ll_row]
ll_seq           = dw_detail.Object.preseq[ll_row]
//2005.11.17 kem Modify 대리점 추가
ls_partner       = dw_detail.object.partner[ll_row]

Select svctype
  into :ls_svctype_cu
  from svcmst
 where svccod = :ls_svccod ;
 
//선불제  0
ls_svctype   = fs_get_control("B0", "P101", ls_ref_desc)
//후불제  1
ls_svctype_1 = fs_get_control("B0", "P102", ls_ref_desc)

If ls_customerid = '' Then
	f_msg_info(9000, Title, "고객번호가 존재하지 않습니다.")
	Return -1
End If

iu_cust_msg = Create u_cust_a_msg
iu_cust_msg.is_pgm_name = "서비스가입예약확정처리 - 개통처리"
iu_cust_msg.is_grp_name = "개통처리"
iu_cust_msg.is_data[1]  = ls_svccod
iu_cust_msg.is_data[2]  = ls_priceplan
iu_cust_msg.is_data[3]  = ls_validkey_type
iu_cust_msg.is_data[4]  = ls_customerid
iu_cust_msg.is_data[5]  = gs_pgm_id[gi_open_win_no]	//Pgm_id
iu_cust_msg.is_data[6]  = ls_validkey  
iu_cust_msg.is_data[7]  = ls_partner
iu_cust_msg.il_data[1]  = ll_seq
iu_cust_msg.idw_data[1] = dw_detail

If ls_svctype = ls_svctype_cu Then
	OpenSheetWithParm(b1w_reg_svc_actorder_pre_reserve_v20_moo, iu_cust_msg, w_mdi_main, 1, Layered!)  

ElseIf ls_svctype_1 = ls_svctype_cu Then
	OpenSheetWithParm(b1w_reg_svc_actorder_reserve_v20_moo, iu_cust_msg, w_mdi_main, 1, Layered!)  
	
Else
	f_msg_info(9000, Title, "선불, 후불 서비스가입예약 고객이 아닙니다.")
	Return -1
End If

end event

type gb_1 from groupbox within b1w_reg_reserve_confirm_v20_moo
integer x = 32
integer y = 308
integer width = 3264
integer height = 1252
integer taborder = 11
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
end type

