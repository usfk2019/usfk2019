$PBExportHeader$b0w_inq_zoncst4_popup_2.srw
$PBExportComments$[kjm] 요율변경
forward
global type b0w_inq_zoncst4_popup_2 from w_base
end type
type p_save from u_p_save within b0w_inq_zoncst4_popup_2
end type
type dw_check from u_d_base within b0w_inq_zoncst4_popup_2
end type
type dw_cond from datawindow within b0w_inq_zoncst4_popup_2
end type
type dw_detail from u_d_external within b0w_inq_zoncst4_popup_2
end type
type p_close from u_p_close within b0w_inq_zoncst4_popup_2
end type
type gb_1 from groupbox within b0w_inq_zoncst4_popup_2
end type
type gb_2 from groupbox within b0w_inq_zoncst4_popup_2
end type
end forward

global type b0w_inq_zoncst4_popup_2 from w_base
integer width = 3607
integer height = 1096
string title = "요율변경"
boolean minbox = false
boolean maxbox = false
boolean resizable = false
windowtype windowtype = response!
windowstate windowstate = normal!
event ue_close ( )
event ue_ok ( )
event type integer ue_save ( )
event type integer ue_extra_save ( )
p_save p_save
dw_check dw_check
dw_cond dw_cond
dw_detail dw_detail
p_close p_close
gb_1 gb_1
gb_2 gb_2
end type
global b0w_inq_zoncst4_popup_2 b0w_inq_zoncst4_popup_2

type variables
u_cust_db_app iu_cust_db_app

end variables

event ue_close();String ls_priceplan,	ls_zoncod,	ls_parttype

str_item returnparm

ls_priceplan = Trim(dw_cond.object.priceplan[1])
IF IsNull(ls_priceplan) OR ls_priceplan = "" THEN
	ls_priceplan = ""
END IF

ls_zoncod = Trim(dw_cond.object.zoncod[1])
IF IsNull(ls_zoncod) OR ls_zoncod = "" THEN
	ls_zoncod = ""
END IF

ls_parttype = Trim(dw_cond.object.parttype[1])
IF IsNull(ls_parttype) OR ls_parttype = "" THEN
	ls_parttype = ""
END IF

returnparm.is_data[1] = ""
returnparm.is_data[2] = ""
returnparm.is_data[3] = ""
returnparm.is_data[4] = ""
returnparm.is_data[5] = ""
returnparm.is_data[6] = ""

returnparm.is_data[3] = ls_priceplan
returnparm.is_data[5] = ls_zoncod
returnparm.is_data[6] = ls_parttype

//messagebox('close', returnparm.is_data[1])
//messagebox('close', returnparm.is_data[2])
//messagebox('close', returnparm.is_data[3])
//messagebox('close', returnparm.is_data[4])
//messagebox('close', returnparm.is_data[5])

CloseWithReturn(This, returnparm)
end event

event type integer ue_save();String ls_priceplan
boolean lb_commit1,	lb_commit2

iu_cust_db_app = create u_cust_db_app

Constant Int LI_ERROR = -1

If dw_cond.AcceptText() < 0 Then
	dw_cond.SetFocus()
	Return LI_ERROR
End If

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return LI_ERROR
End If

If dw_check.AcceptText() < 0 Then
	dw_check.SetFocus()
	Return LI_ERROR
End If


If This.Trigger Event ue_extra_save() < 0 Then
	dw_cond.SetFocus()
	Return LI_ERROR
End If

If dw_detail.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If

//	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return LI_ERROR
	End If
	
	lb_commit1 = true
End If

If dw_check.Update() < 0 then
	//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_check.SetFocus()
		Return LI_ERROR
	End If

//	f_msg_info(3010,This.Title,"Save")
	Return LI_ERROR
Else
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_check.SetFocus()
		Return LI_ERROR
	End If
	
	lb_commit2 = true
End If

IF lb_commit1 and lb_commit2 THEN
	f_msg_info(3000,This.Title,"Save")		
	PostEvent ('ue_close')
END IF

Return 0


end event

event type integer ue_extra_save();//표준 요금 조회
String ls_priceplan, ls_pgm_id, ls_priceplan_old,	ls_zoncod,	ls_tmcod,	ls_opendt,	ls_enddt,	ls_parttype

Long ll_row, i, 	ll_baserate, ll_cnt,	ll_rate1,	ll_rate2,	ll_rate3,	ll_rate4,	ll_rate5,	&
	  ll_baseamt,	ll_amt1,		ll_amt2,		ll_amt3,	ll_amt4,		ll_amt5,		ll_mod,		ll_nextval
	  
Dec ldc_tmrange1, ldc_tmrange2,	ldc_tmrange3,	ldc_tmrange4,	ldc_tmrange5,	&
	 ldc_addamt, ldc_baseamt_1, ldc_unitfee_1
		 
Dec ldc_unitsec,	ldc_unitsec1,	ldc_unitsec2,	ldc_unitsec3,	ldc_unitsec4,	ldc_unitsec5,	&
	 ldc_unitfee_2, ldc_unitfee_3, ldc_unitfee_4, ldc_unitfee_5

//멘트(요금, 범위, 단위)
Dec ldc_munitfee,		ldc_munitfee1,		ldc_munitfee2,		ldc_munitfee3,		ldc_munitfee4,		ldc_munitfee5,	&	
	 ldc_mtmrange1,	ldc_mtmrange2,		ldc_mtmrange3,		ldc_mtmrange4,		ldc_mtmrange5,	&
	 ldc_munitsec1,	ldc_munitsec2,		ldc_munitsec3,		ldc_munitsec4,		ldc_munitsec5

//기본(요금, 범위, 단위) 
Dec ldc_unitfee,		ldc_unitfee1,			ldc_unitfee2,			ldc_unitfee3,			ldc_unitfee4,		ldc_unitfee5,	&	
	 ldc_tmrange1_1,	ldc_tmrange2_1,		ldc_tmrange3_1,		ldc_tmrange4_1,		ldc_tmrange5_1,	&
	 ldc_unitsec1_1,	ldc_unitsec2_1,		ldc_unitsec3_1,		ldc_unitsec4_1,		ldc_unitsec5_1
	 
DateTime ldt_sysdate
Integer li_result

//조회용 변수
String ls_where, ls_old_sql,	ls_new_sql

str_item Newparm
Newparm = Message.PowerObjectParm

ldt_sysdate = fdt_get_dbserver_now()

ls_parttype = Trim(dw_cond.object.parttype[1])
ls_priceplan = Trim(dw_cond.object.priceplan[1])
ls_pgm_id = Newparm.is_data[4]
ls_zoncod = Trim(dw_cond.object.zoncod[1])
ls_tmcod = Trim(dw_cond.object.tmcod[1])
ls_opendt = String(dw_cond.object.opendt[1],'yyyymmdd')
ls_enddt = String(dw_cond.object.enddt[1],'yyyymmdd')



//필수 항목 Check
IF ls_parttype = 'R' THEN
	If IsNull(ls_priceplan) Then ls_priceplan = ""
	
	If ls_priceplan = "" Then
		f_msg_info(200, Title,"Price Plan")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
		Return -1
	End If
ELSE
	ls_priceplan = 'ALL'
END IF

IF IsNull(ls_opendt) Then ls_opendt = ""

IF ls_opendt = "" THEN
	f_msg_info(200, Title,"변경적용시작일")
	dw_cond.SetColumn("opendt")
	dw_cond.SetFocus()	
   Return -1
END IF

IF IsNull(ls_enddt) THEN ls_enddt = ""

IF ls_enddt <> "" THEN
	IF ls_opendt > ls_enddt THEN
		f_msg_usr_err(9000, Title, "적용종료일은 적용시작일보다 크거나 같아야 합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("opendt")
		RETURN -1
	END IF		
END IF

ls_old_sql = dw_check.GetSqlSelect()

ls_where = ""

IF ls_priceplan <> "" THEN
	ls_where = "WHERE priceplan = '" + ls_priceplan + "'"	
END IF

IF ls_opendt <> "" THEN
	ls_where += "and to_char(opendt, 'yyyymmdd') >= '" + ls_opendt + "'"	
END IF

IF ls_enddt <> "" THEN
	ls_where += " and to_char(enddt,'YYYYMMDD') <= '" + ls_enddt  + "' "
END IF

IF ls_zoncod <> "" THEN
	ls_where += " and zoncod = '" + ls_zoncod  + "' "
END IF

IF ls_tmcod <> "" THEN
	ls_where += " and tmcod = '" + ls_tmcod  + "' "
END IF

ls_new_sql = ls_old_sql + ls_where
//messagebox('ls_new_sql', ls_new_sql)
dw_check.SetSQLSelect(ls_new_sql)
ll_row = dw_check.Retrieve()
//messagebox('ll_row', ll_row)
dw_check.SetSQLSelect(ls_old_sql)

If ll_row = 0 Then
	f_msg_info(1000, Title, "")
	Return -1	
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -1
End If

// 정률
ll_baserate = dw_detail.object.unitfee_rate[1]
ll_rate1 = dw_detail.object.unitfee1_rate[1]
ll_rate2 = dw_detail.object.unitfee2_rate[1]
ll_rate3 = dw_detail.object.unitfee3_rate[1]
ll_rate4 = dw_detail.object.unitfee4_rate[1]
ll_rate5 = dw_detail.object.unitfee5_rate[1]

IF IsNull(ll_baserate) THEN ll_baserate = 0
IF IsNull(ll_rate1) THEN ll_rate1 = 0
IF IsNull(ll_rate2) THEN ll_rate2 = 0
IF IsNull(ll_rate3) THEN ll_rate3 = 0
IF IsNull(ll_rate4) THEN ll_rate4 = 0
IF IsNull(ll_rate5) THEN ll_rate5 = 0

// 정액
ll_baseamt = dw_detail.object.unitfee_amt[1]
ll_amt1 = dw_detail.object.unitfee1_amt[1]
ll_amt2 = dw_detail.object.unitfee2_amt[1]
ll_amt3 = dw_detail.object.unitfee3_amt[1]
ll_amt4 = dw_detail.object.unitfee4_amt[1]
ll_amt5 = dw_detail.object.unitfee5_amt[1]

IF IsNull(ll_baseamt) THEN ll_baseamt = 0
IF IsNull(ll_amt1) THEN ll_amt1 = 0
IF IsNull(ll_amt2) THEN ll_amt2 = 0
IF IsNull(ll_amt3) THEN ll_amt3 = 0
IF IsNull(ll_amt4) THEN ll_amt4 = 0
IF IsNull(ll_amt5) THEN ll_amt5 = 0

//범위
ldc_tmrange1 = dw_detail.object.tmrange1[1]
ldc_tmrange2 = dw_detail.object.tmrange2[1]
ldc_tmrange3 = dw_detail.object.tmrange3[1]
ldc_tmrange4 = dw_detail.object.tmrange4[1]
ldc_tmrange5 = dw_detail.object.tmrange5[1]

IF IsNull(ldc_tmrange1) THEN ldc_tmrange1 = 0
IF IsNull(ldc_tmrange2) THEN ldc_tmrange2 = 0
IF IsNull(ldc_tmrange3) THEN ldc_tmrange3 = 0
IF IsNull(ldc_tmrange4) THEN ldc_tmrange4 = 0
IF IsNull(ldc_tmrange5) THEN ldc_tmrange5 = 0

//단위
ldc_unitsec = dw_detail.object.unitsec[1]
ldc_unitsec1 = dw_detail.object.unitsec1[1]
ldc_unitsec2 = dw_detail.object.unitsec2[1]
ldc_unitsec3 = dw_detail.object.unitsec3[1]
ldc_unitsec4 = dw_detail.object.unitsec4[1]
ldc_unitsec5 = dw_detail.object.unitsec5[1]

IF IsNull(ldc_unitsec) THEN ldc_unitsec = 0
IF IsNull(ldc_unitsec1) THEN ldc_unitsec1 = 0
IF IsNull(ldc_unitsec2) THEN ldc_unitsec2 = 0
IF IsNull(ldc_unitsec3) THEN ldc_unitsec3 = 0
IF IsNull(ldc_unitsec4) THEN ldc_unitsec4 = 0
IF IsNull(ldc_unitsec5) THEN ldc_unitsec5 = 0

IF ldc_tmrange1 > 0 AND ldc_unitsec1 > 0 THEN
	ll_mod = Mod(ldc_tmrange1, ldc_unitsec1)
	
	IF ll_mod <> 0 THEN
		f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
		dw_detail.SetColumn("tmrange1")
		dw_detail.SetFocus()
		Return -1
	End If
		
END IF

IF ldc_tmrange2 > 0 AND ldc_unitsec2 > 0 THEN
	ll_mod = Mod(ldc_tmrange2, ldc_unitsec2)
	
	IF ll_mod <> 0 THEN
		f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
		dw_detail.SetColumn("tmrange2")
		dw_detail.SetFocus()
		Return -1
	End If
		
END IF

IF ldc_tmrange3 > 0 AND ldc_unitsec3 > 0 THEN
	ll_mod = Mod(ldc_tmrange3, ldc_unitsec3)
	
	IF ll_mod <> 0 THEN
		f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
		dw_detail.SetColumn("tmrange3")
		dw_detail.SetFocus()
		Return -1
	End If
		
END IF

IF ldc_tmrange4 > 0 AND ldc_unitsec4 > 0 THEN
	ll_mod = Mod(ldc_tmrange4, ldc_unitsec4)
	
	IF ll_mod <> 0 THEN
		f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
		dw_detail.SetColumn("tmrange4")
		dw_detail.SetFocus()
		Return -1
	End If
		
END IF

IF ldc_tmrange5 > 0 AND ldc_unitsec5 > 0 THEN
	ll_mod = Mod(ldc_tmrange5, ldc_unitsec5)
	
	IF ll_mod <> 0 THEN
		f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
		dw_detail.SetColumn("tmrange5")
		dw_detail.SetFocus()
		Return -1
	End If
		
END IF

//데이터 조작
For i = 1 To dw_check.Rowcount()
	
	
	
	//정액 정률 계산 = 요금 + (요금 * 정률) + 정액
	ldc_munitfee = dw_check.object.munitfee[i]
	ldc_unitfee = ldc_munitfee + (ldc_munitfee * (ll_baserate / 100 )) + ll_baseamt
	dw_check.object.unitfee[i] = ldc_unitfee

	ldc_munitfee1 = dw_check.object.munitfee1[i]
	ldc_unitfee1 = ldc_munitfee1 + (ldc_munitfee1 * (ll_rate1 / 100 )) + ll_amt1
	dw_check.object.unitfee1[i] = ldc_unitfee1

	ldc_munitfee2 = dw_check.object.munitfee2[i]
	ldc_unitfee2 = ldc_munitfee2 + (ldc_munitfee2 * (ll_rate2 / 100 )) + ll_amt2
	dw_check.object.unitfee2[i] = ldc_unitfee2

	ldc_munitfee3 = dw_check.object.munitfee3[i]
	ldc_unitfee3 = ldc_munitfee3 + (ldc_munitfee3 * (ll_rate3 / 100 )) + ll_amt3
	dw_check.object.unitfee3[i] = ldc_unitfee3

	ldc_munitfee4 = dw_check.object.munitfee4[i]
	ldc_unitfee4 = ldc_munitfee4 + (ldc_munitfee4 * (ll_rate4 / 100 )) + ll_amt4
	dw_check.object.unitfee4[i] = ldc_unitfee4

	ldc_munitfee5 = dw_check.object.munitfee5[i]
	ldc_unitfee5 = ldc_munitfee5 + (ldc_munitfee5 * (ll_rate5 / 100 )) + ll_amt5
	dw_check.object.unitfee5[i] = ldc_unitfee5
	
	//시간대시간범위와 시간대 시간단위를 입력하지 않으면 ment의 범위와 시간단위를 가져온다.
	ldc_tmrange1 = 0;	ldc_tmrange2 = 0;	ldc_tmrange3 = 0;	ldc_tmrange4 = 0;	ldc_tmrange5 = 0
	ldc_unitsec = 0;	ldc_unitsec1 = 0;	ldc_unitsec2 = 0;	ldc_unitsec3 = 0;	ldc_unitsec4 = 0;	ldc_unitsec5 = 0;
	
	IF ldc_tmrange1 = 0 THEN ldc_tmrange1 = dw_check.object.mtmrange1[i]
	IF ldc_tmrange2 = 0 THEN ldc_tmrange2 = dw_check.object.mtmrange2[i]	
	IF ldc_tmrange3 = 0 THEN ldc_tmrange3 = dw_check.object.mtmrange3[i]		
	IF ldc_tmrange4 = 0 THEN ldc_tmrange4 = dw_check.object.mtmrange4[i]			
	IF ldc_tmrange5 = 0 THEN ldc_tmrange5 = dw_check.object.mtmrange5[i]				

	IF ldc_unitsec = 0 THEN ldc_unitsec = dw_check.object.munitsec[i]			
	IF ldc_unitsec1 = 0 THEN ldc_unitsec1 = dw_check.object.munitsec1[i]
	IF ldc_unitsec2 = 0 THEN ldc_unitsec2 = dw_check.object.munitsec2[i]
	IF ldc_unitsec3 = 0 THEN ldc_unitsec3 = dw_check.object.munitsec3[i]
	IF ldc_unitsec4 = 0 THEN ldc_unitsec4 = dw_check.object.munitsec4[i]
	IF ldc_unitsec5 = 0 THEN ldc_unitsec5 = dw_check.object.munitsec5[i]
	
	dw_check.object.tmrange1[i] = ldc_tmrange1
	dw_check.object.tmrange2[i] = ldc_tmrange2	
	dw_check.object.tmrange3[i] = ldc_tmrange3		
	dw_check.object.tmrange4[i] = ldc_tmrange4
	dw_check.object.tmrange5[i] = ldc_tmrange5	

	dw_check.object.unitsec[i] = ldc_unitsec		
	dw_check.object.unitsec1[i] = ldc_unitsec1
	dw_check.object.unitsec2[i] = ldc_unitsec2	
	dw_check.object.unitsec3[i] = ldc_unitsec3		
	dw_check.object.unitsec4[i] = ldc_unitsec4
	dw_check.object.unitsec5[i] = ldc_unitsec5		
	
//	// insert는 일어나지 않는다.
	dw_check.object.pgm_id[i] = ls_pgm_id
	dw_check.object.updt_user[i] = gs_user_id
	dw_check.object.updtdt[i] = ldt_sysdate
	
Next	

SELECT SEQ_ZONCST2LOG.nextval
  INTO :ll_nextval
  FROM DUAL;
  
dw_detail.object.seq[1] = ll_nextval	
dw_detail.object.priceplan[1] = ls_priceplan
dw_detail.object.zoncod[1] = ls_zoncod
dw_detail.object.tmcod[1] = ls_tmcod
dw_detail.object.fromdt[1] = datetime(dw_cond.object.opendt[1])
dw_detail.object.todt[1] = datetime(dw_cond.object.enddt[1])
dw_detail.object.crt_user[1] = gs_user_id
dw_detail.object.crtdt[1] = ldt_sysdate
dw_detail.object.pgm_id[1] = gs_pgm_id[1]

RETURN 0

end event

on b0w_inq_zoncst4_popup_2.create
int iCurrent
call super::create
this.p_save=create p_save
this.dw_check=create dw_check
this.dw_cond=create dw_cond
this.dw_detail=create dw_detail
this.p_close=create p_close
this.gb_1=create gb_1
this.gb_2=create gb_2
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_save
this.Control[iCurrent+2]=this.dw_check
this.Control[iCurrent+3]=this.dw_cond
this.Control[iCurrent+4]=this.dw_detail
this.Control[iCurrent+5]=this.p_close
this.Control[iCurrent+6]=this.gb_1
this.Control[iCurrent+7]=this.gb_2
end on

on b0w_inq_zoncst4_popup_2.destroy
call super::destroy
destroy(this.p_save)
destroy(this.dw_check)
destroy(this.dw_cond)
destroy(this.dw_detail)
destroy(this.p_close)
destroy(this.gb_1)
destroy(this.gb_2)
end on

event open;/*-------------------------------------------------------
	Name	: b0w_inq_zoncst4_popup_2
	Desc.	: 요율변경
	Ver.	: 1.0
	Date	: 2004.08.12
	Programer : Kwon Jung Min(KJM)
---------------------------------------------------------*/
str_item Newparm
Newparm = Message.PowerObjectParm

f_center_window(This)


IF Newparm.is_data[5] <> "" THEN
	dw_cond.object.zoncod[1] = Newparm.is_data[5]
END IF

IF Newparm.is_data[6] <> "" THEN
	dw_cond.object.parttype[1] = Newparm.is_data[6]	

	IF Newparm.is_data[6] = 'R' THEN
		
		dw_cond.object.priceplan_t.visible = 1
		dw_cond.object.priceplan.visible = 1
		
		IF Newparm.is_data[3] <> "" THEN
			dw_cond.object.priceplan[1] = Newparm.is_data[3]
		END IF
	END IF
	
END IF

//p_save.TriggerEvent('ue_disable')

Return 0 

end event

event close;//
end event

type p_save from u_p_save within b0w_inq_zoncst4_popup_2
integer x = 3282
integer y = 52
boolean originalsize = false
end type

type dw_check from u_d_base within b0w_inq_zoncst4_popup_2
boolean visible = false
integer x = 27
integer y = 1072
integer width = 3237
integer height = 476
integer taborder = 20
boolean enabled = false
string dataobject = "b0dw_reg_zoncst3_check_1"
boolean controlmenu = true
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

type dw_cond from datawindow within b0w_inq_zoncst4_popup_2
integer x = 37
integer y = 56
integer width = 3209
integer height = 204
integer taborder = 20
string title = "none"
string dataobject = "b0dw_cnd_inq_zoncst4_popup_2"
boolean border = false
boolean livescroll = true
end type

event constructor;This.SetTransObject(sqlca)

This.InsertRow(0)
end event

event itemchanged;CHOOSE CASE dwo.name
	CASE 'parttype'		
		
		IF data = 'R' THEN			//가격정책 요율이면 보이고, 기본요율이면 안 보이게...
			
			This.object.priceplan_t.visible = 1
			This.object.priceplan.visible = 1	
			
			This.object.priceplan[row] = ""
		ELSE

			This.object.priceplan_t.visible = 0
			This.object.priceplan.visible = 0	
		END IF
		
		This.object.zoncod[row] = ""		
		This.object.tmcod[row] = ""	
END CHOOSE
end event

type dw_detail from u_d_external within b0w_inq_zoncst4_popup_2
integer x = 41
integer y = 340
integer width = 3205
integer height = 644
integer taborder = 10
string dataobject = "b0dw_inq_zoncst4_popup_2"
boolean hscrollbar = false
boolean vscrollbar = false
boolean border = false
boolean livescroll = false
borderstyle borderstyle = stylebox!
end type

event itemchanged;call super::itemchanged;Long ll_tmrange1,		ll_tmrange2,		ll_tmrange3,		ll_tmrange4,	ll_tmrange5,	ll_mod

//p_save.TriggerEvent('ue_enable')

CHOOSE CASE dwo.name
	Case "unitsec1"
		ll_tmrange1 = This.object.tmrange1[row]
		
		If ll_tmrange1 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_tmrange1, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange1")
				Return -1
			End If
		End If
	Case "unitsec2"
		ll_tmrange2 = This.object.tmrange2[row]
		
		If ll_tmrange2 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_tmrange2, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange2")
				Return -1
			End If
		End If
	Case "unitsec3"
		ll_tmrange3 = This.object.tmrange3[row]
		
		If ll_tmrange3 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_tmrange3, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange3")
				Return -1
			End If
		End If
	Case "unitsec4"
		ll_tmrange4 = This.object.tmrange4[row]
		
		If ll_tmrange4 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_tmrange4, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange4")
				Return -1
			End If
		End If
	Case "unitsec5"
		ll_tmrange5 = This.object.tmrange5[row]
		
		If ll_tmrange1 > 0 And Long(data) > 0 Then
			ll_mod = Mod(ll_tmrange5, Long(data))
		
			If ll_mod <> 0 Then
				f_msg_info(9000, Title, "시간범위를 단위시간으로 나누었을때 값이 맞지 않습니다. 다시 입력하십시요.")
				This.SetColumn("tmrange1")
				Return -1
			End If
		End If

END CHOOSE
end event

type p_close from u_p_close within b0w_inq_zoncst4_popup_2
integer x = 3282
integer y = 160
boolean originalsize = false
end type

type gb_1 from groupbox within b0w_inq_zoncst4_popup_2
integer x = 23
integer y = 284
integer width = 3241
integer height = 716
integer taborder = 20
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

type gb_2 from groupbox within b0w_inq_zoncst4_popup_2
integer x = 23
integer width = 3241
integer height = 280
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 33554432
long backcolor = 29478337
borderstyle borderstyle = stylelowered!
end type

