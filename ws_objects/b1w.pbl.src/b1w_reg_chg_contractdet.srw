$PBExportHeader$b1w_reg_chg_contractdet.srw
$PBExportComments$[ceusee] 계약상세품목 변경
forward
global type b1w_reg_chg_contractdet from w_a_reg_m_m3
end type
type dw_validkey from u_d_base within b1w_reg_chg_contractdet
end type
end forward

global type b1w_reg_chg_contractdet from w_a_reg_m_m3
integer width = 3186
integer height = 2196
dw_validkey dw_validkey
end type
global b1w_reg_chg_contractdet b1w_reg_chg_contractdet

type variables
String is_active
String is_term
Boolean ib_modify
String is_contractseq
String is_orderno
String is_priceplan

end variables

forward prototypes
public function integer wfi_get_customerid (string as_customerid)
end prototypes

public function integer wfi_get_customerid (string as_customerid);/*------------------------------------------------------------------------
	Name	: wfi_get_customerid
	Desc	: 고객 Id 구하기]
	Date	: 2002.10.01
	Arg.	: string as_customerid
	Retrun	: integer
	 			-1 : Error
	Ver.	: 1.0
	programer : Choi Bo Ra (ceusee)
------------------------------------------------------------------------*/
String ls_customernm
Select customernm
Into :ls_customernm
From customerm
Where customerid = :as_customerid;

If SQLCA.SQLCode = 100 Then		//Not Found
   f_msg_usr_err(201, Title, "고객번호")
   dw_cond.SetFocus()
   dw_cond.SetColumn("customerid")
   Return -1
End If

dw_cond.object.customernm[1] = ls_customernm
Return 0
end function

on b1w_reg_chg_contractdet.create
int iCurrent
call super::create
this.dw_validkey=create dw_validkey
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.dw_validkey
end on

on b1w_reg_chg_contractdet.destroy
call super::destroy
destroy(this.dw_validkey)
end on

event open;call super::open;/*------------------------------------------------------------------------
	Name	:	bw1_reg_chg_priceplan
	Desc	:	가격정책 변경
	Ver.	:	1.0
	Date	:	2002.10.12
-------------------------------------------------------------------------*/
String ls_ref_desc, ls_name[], ls_status
is_active = ""
is_term = ""


//개통 상태코드
ls_ref_desc =""
is_active = fs_get_control("B0", "P223", ls_ref_desc)

//해지 상태코드
ls_status = fs_get_control("B0", "P221", ls_ref_desc)
fi_cut_string(ls_status, ";", ls_name[])		
is_term = ls_name[2]

end event

event ue_ok();call super::ue_ok;//조회
String ls_customerid, ls_where
Long ll_row

ls_customerid = Trim(dw_cond.object.customerid[1])
If IsNull(ls_customerid) Then ls_customerid = ""
If ls_customerid = "" Then
	f_msg_info(200, Title, "고객번호")
	dw_cond.SetFocus()
	dw_cond.SetColumn("customerid")
	Return
Else
	 ll_row = wfi_get_customerid(ls_customerid)  //올바른 고객인지 확인	 
	 If ll_row = -1 Then  Return
End If

ls_where = "con.customerid = '" + ls_customerid + "' "
dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row = 0 Then
	f_msg_info(1000, Title , "")
ElseIf ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
   Return
Else
	dw_master.event ue_select()
End If

Return 
	


end event

event ue_extra_save(ref integer ai_return);call super::ue_extra_save;b1u_dbmgr3 	lu_dbmgr3
Integer li_rc
String ls_where, ls_contractseq
Long ll_row
lu_dbmgr3 = Create b1u_dbmgr3

//dw_validkey.reset()
//khpark add (가격정책 변경 시 변경전 계약건의 조건에 맞는
//			  validkey정보를  update 하기전에 retrieve해서 가지고 있다가 insert 하기 위해)
ls_contractseq = string(dw_detail2.object.contractmst_contractseq[1])

ls_where = " use_yn = 'Y' and status = '" + is_active + "'" + &
		   " and to_char(contractseq) = '" + String(ls_contractseq) + "'"
		   
//dw_validkey.is_where = ls_where
//ll_row = dw_validkey.Retrieve()
//If ll_row < 0 Then
//   f_msg_usr_err(2100, Title, "dw_validkey Retrieve()")
//   Return
//End If

lu_dbmgr3.is_caller = "b1w_reg_chg_contractdet%save"
lu_dbmgr3.is_title = Title
lu_dbmgr3.is_data[1] = is_contractseq
lu_dbmgr3.is_data[2] = is_orderno
lu_dbmgr3.is_data[3] = gs_user_group
lu_dbmgr3.is_data[4] = gs_user_id
lu_dbmgr3.is_data[5] = gs_pgm_id[gi_open_win_no]
lu_dbmgr3.idw_data[1] = dw_detail2
lu_dbmgr3.idw_data[2] = dw_detail
//lu_dbmgr3.idw_data[3] = dw_validkey   //khpark add

lu_dbmgr3.uf_prc_db_02()
li_rc = lu_dbmgr3.ii_rc

If li_rc < 0 Then
	Destroy lu_dbmgr3
	ai_return = li_rc
	Return 
End If

Destroy lu_dbmgr3
ai_return = 0

Return 
end event

event type integer ue_save();Int li_return

ii_error_chk = -1

If dw_detail.AcceptText() < 0 Then
	dw_detail.SetFocus()
	Return -1
End if

This.Trigger Event ue_extra_save(li_return)

If li_return = -1  Then
//ROLLBACK와 동일한 기능
	iu_cust_db_app.is_caller = "ROLLBACK"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()
	
	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return  -1
	End If
	f_msg_info(3010,This.Title,This.Title)
	Return -1
ElseIf li_return = 0 Then
	
	//COMMIT와 동일한 기능
	iu_cust_db_app.is_caller = "COMMIT"
	iu_cust_db_app.is_title = This.Title

	iu_cust_db_app.uf_prc_db()

	If iu_cust_db_app.ii_rc = -1 Then
		dw_detail.SetFocus()
		Return -1
	End If
	f_msg_info(3000,This.Title,This.Title)
ElseIf li_return  = -2 Then
	Return -1
	
End if

dw_detail.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.
dw_detail2.SetitemStatus(1, 0, Primary!, NotModified!)   //수정 안되었다고 인식.

//다시 Reset
String ls_customerid
ls_customerid = Trim(dw_cond.object.customerid[1])

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.object.customerid[1] = ls_customerid

Trigger Event ue_ok()

ii_error_chk = 0

Return 0
end event

event ue_reset();Int li_rc, li_ret
Long ll_row
String ls_status 
ii_error_chk = -1

ll_row = dw_master.GetSelectedRow(0)
If ll_row <= 0 Then  Return


//상태 코드 
ls_status = Trim(dw_master.object.status[1])


dw_detail.AcceptText()

If ls_status = is_active Then
	If dw_detail.ModifiedCount() > 0 or &
		dw_detail.DeletedCount() > 0 or &
		dw_detail2.ModifiedCount() > 0 or &
		dw_detail2.DeletedCount() > 0 then
		
		li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
		CHOOSE CASE li_ret
			CASE 1
				li_ret = -1 
				li_ret = Event ue_save()
				If Isnull( li_ret ) or li_ret < 0 then return
			CASE 2
	
			CASE ELSE
				Return 
		END CHOOSE
			
	end If

End If

p_insert.TriggerEvent("ue_disable")
p_delete.TriggerEvent("ue_disable")
p_save.TriggerEvent("ue_disable")
p_reset.TriggerEvent("ue_disable")
p_ok.TriggerEvent("ue_enable")

dw_detail.Reset()
dw_detail2.Reset()
dw_master.Reset()
dw_cond.Enabled = True
dw_cond.Reset()
dw_cond.InsertRow(0)
dw_cond.SetFocus()

ii_error_chk = 0

end event

type dw_cond from w_a_reg_m_m3`dw_cond within b1w_reg_chg_contractdet
integer x = 59
integer y = 56
integer width = 1527
integer height = 116
string dataobject = "b1dw_cnd_reg_chg_priceplan"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::doubleclicked;call super::doubleclicked;Choose Case dwo.name
	Case "customerid"
		If dw_cond.iu_cust_help.ib_data[1] Then
			 dw_cond.Object.customerid[row] = &
			 dw_cond.iu_cust_help.is_data[1]
			 dw_cond.object.customernm[row] = &
			 dw_cond.iu_cust_help.is_data[2]
		End If
End Choose
end event

event dw_cond::ue_init();call super::ue_init;//Help Window
This.idwo_help_col[1] = This.Object.customerid
This.is_help_win[1] = "b1w_hlp_customerm"
This.is_data[1] = "CloseWithReturn"
end event

type p_ok from w_a_reg_m_m3`p_ok within b1w_reg_chg_contractdet
integer x = 1728
integer y = 40
end type

type p_close from w_a_reg_m_m3`p_close within b1w_reg_chg_contractdet
integer x = 2043
integer y = 40
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m3`gb_cond within b1w_reg_chg_contractdet
integer width = 1577
integer height = 212
end type

type dw_master from w_a_reg_m_m3`dw_master within b1w_reg_chg_contractdet
integer y = 224
integer width = 3081
integer height = 452
string dataobject = "b1dw_inq_chg_contractdet"
end type

event dw_master::ue_select();Long ll_selected_row 
Integer li_return, li_ret


ll_selected_row = GetSelectedRow( 0 )

If dw_detail.ModifiedCount() > 0 or &
	dw_detail.DeletedCount() > 0 or &
	dw_detail2.ModifiedCount() > 0 or &
	dw_detail2.DeletedCount() > 0 then
	
	li_ret = MessageBox(Title, "Data is Modified.! Do you want to save?", Question!, YesNoCancel!, 1)
	CHOOSE CASE li_ret
		CASE 1
			li_ret = Parent.Event ue_save()
			If isnull( li_ret ) or li_ret < 0 then return
		CASE 2
		CASE ELSE
			Return
	END CHOOSE
		
end If


//순서 바꿈
dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
If li_return < 0 Then
	Return
End If
	
//dw_detail.Event ue_retrieve(ll_selected_row,li_return)
//If li_return < 0 Then
//	Return
//End If

end event

event dw_master::clicked;call super::clicked;String ls_status
If row = 0 Then Return 0
ls_status = Trim(dw_master.object.status[row])
//개통상태가 아니면
If ls_status <> is_active Then
	p_save.TriggerEvent("ue_disable")
Else
	p_save.TriggerEvent("ue_enable")
End If

end event

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.contractseq_t
uf_init(ldwo_sort, "D", RGB(0,0,128))
end event

event dw_master::retrieveend;call super::retrieveend;IF rowcount > 0 THEN
	//가격정책
	is_priceplan = String(dw_master.object.priceplan[1])
ELSE	
	is_priceplan = ""
END IF
end event

type dw_detail from w_a_reg_m_m3`dw_detail within b1w_reg_chg_contractdet
integer y = 1380
integer width = 3081
integer height = 520
string dataobject = "b1dw_reg_chg_priceplan_1"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(off!)
end event

event dw_detail::retrieveend;call super::retrieveend;Long i
String ls_mainitem_yn
String ls_itemcod
Long ll_cnt

//If rowcount = 0 Then
//	p_save.TriggerEvent("ue_disable")
//End If

For i = 1 To rowcount 
	If dw_detail.object.mainitem_yn[i] = "Y" Then
//		dw_detail.object.itemcod.Color = RGB(255,0,255)
//		dw_detail.object.itemnm.Color = RGB(255,0,255)
//		dw_detail.object.quota_yn.Color = RGB(255,0,255)
//		dw_detail.object.chk.Color = RGB(255,0,255)
		dw_detail.object.chk[i] = "Y"
	Else
//		dw_detail.object.itemcod.Color = RGB(0,0,0)
//		dw_detail.object.itemnm.Color = RGB(0,0,0)
//		dw_detail.object.quota_yn.Color = RGB(0,0,0)
//		dw_detail.object.chk.Color = RGB(0,0,0)
	End If
	
	//현재 등록되어 있는 아이템이면 선택한다.
	ls_itemcod = dw_detail.object.itemcod[i]
	
	SELECT count(*)
	INTO :ll_cnt
	FROM contractdet
	WHERE contractseq = :is_contractseq
	AND itemcod = :ls_itemcod;
	
	IF ll_cnt = 1 THEN
		dw_detail.object.chk[i] = "Y"
	END IF
	
	dw_detail.SetItemStatus(i, 0 , Primary!,NotModified!)

Next

end event

event dw_detail::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_priceplan, ls_where, ls_status
Long ll_row

If al_select_row = 0 Then Return 
ls_priceplan = is_priceplan

IF IsNull(ls_priceplan) THEN ls_priceplan = ""

ls_where = ""
ls_where += "det.priceplan = '" + ls_priceplan + "' "
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	p_save.TriggerEvent("ue_disable")
	ai_return = -1
	Return 
ELSEIF ll_row = 0 THEN
	p_save.TriggerEvent("ue_disable")
ELSEIF ib_modify THEN
	p_save.TriggerEvent("ue_enable")
ELSE	
	p_save.TriggerEvent("ue_disable")
END IF

Return 
end event

type p_insert from w_a_reg_m_m3`p_insert within b1w_reg_chg_contractdet
boolean visible = false
integer y = 1980
end type

type p_delete from w_a_reg_m_m3`p_delete within b1w_reg_chg_contractdet
boolean visible = false
integer y = 1980
end type

type p_save from w_a_reg_m_m3`p_save within b1w_reg_chg_contractdet
integer x = 59
integer y = 1952
end type

type p_reset from w_a_reg_m_m3`p_reset within b1w_reg_chg_contractdet
integer x = 361
integer y = 1952
end type

type dw_detail2 from w_a_reg_m_m3`dw_detail2 within b1w_reg_chg_contractdet
integer y = 708
integer width = 3077
integer height = 640
string dataobject = "b1dw_reg_chg_contractdet"
boolean hscrollbar = false
boolean vscrollbar = false
boolean hsplitscroll = false
boolean livescroll = false
end type

event dw_detail2::ue_retrieve(long al_select_row, ref integer ai_return);call super::ue_retrieve;String ls_contractseq, ls_where, ls_status
String ls_customerid
String ls_reqdt
String ls_bil_fromdt
Long ll_row
Long ll_selected_row
Int li_return


If al_select_row = 0 Then Return 

is_contractseq = String(dw_master.object.contractseq[al_select_row])

SELECT orderno
INTO :is_orderno
FROM contractdet
WHERE contractseq = :is_contractseq;

IF SQLCA.sqlcode < 0 THEN
	
END IF

ls_status = Trim(dw_master.object.status[al_select_row])
ls_customerid = Trim(dw_master.object.customerid[al_select_row])
ls_bil_fromdt = String(dw_master.object.bil_fromdt[al_select_row],"YYYYMMDD")

ls_where = ""
ls_where += "to_char(cmt.contractseq) = '" + is_contractseq + "' "
dw_detail2.is_where = ls_where
ll_row = dw_detail2.Retrieve()
If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	ai_return = -1
	Return
End If

dw_detail2.SetItemStatus(1, 0 , Primary!,NotModified!)



//청구기준일
SELECT to_char(req.reqdt,'YYYYMMDD') 
INTO :ls_reqdt
FROM customerm cus, billinginfo bil, reqconf req
WHERE cus.payid = bil.customerid
AND bil.bilcycle = req.chargedt
AND cus.customerid = :ls_customerid;

IF SQLCA.sqlcode < 0 THEN
	RETURN
END IF


//계약상태가 개통이고 과금시작일이 청구기준일 이후면 계약정보및 품목을 변경할 수 있다.
IF ls_status = is_active AND ls_reqdt <= ls_bil_fromdt THEN
	dw_detail2.enabled = true
	dw_detail.enabled = true
	ib_modify = true
Else
	dw_detail2.enabled = false
	dw_detail.enabled = false
	ib_modify = false
END IF


ll_selected_row = dw_master.GetSelectedRow( 0 )

dw_detail.Event ue_retrieve(ll_selected_row,li_return)

Return 
end event

event dw_detail2::retrieveend;call super::retrieveend;DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist, ll_selected_row
Integer li_return
String ls_filter, ls_svccod, ls_customerid, ls_currency_type


If rowcount = 0 Then Return 0

//고객의 납입자의 화폐단위 가져오기
ls_customerid = dw_detail2.object.customerm_customerid[1] 
select currency_type into :ls_currency_type from billinginfo bil, customerm cus
where bil.customerid = cus.payid and  cus.customerid =:ls_customerid;

ls_svccod = Trim(dw_detail2.object.contractmst_svccod[1])
li_exist = dw_detail2.GetChild("contractmst_priceplan", ldc_priceplan)		//DDDW 구함
If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Price Plan")
ls_filter = "svccod = '" + ls_svccod  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " + &
             " And currency_type ='" + ls_currency_type + "' "

ldc_priceplan.SetTransObject(SQLCA)
li_exist =ldc_priceplan.Retrieve()
ldc_priceplan.SetFilter(ls_filter)			//Filter정함
ldc_priceplan.Filter()

If li_exist < 0 Then 				
  f_msg_usr_err(2100, Title, "Retrieve()")
  Return 1  		//선택 취소 focus는 그곳에
End If  
end event

event dw_detail2::itemchanged;call super::itemchanged;DataWindowChild ldc_priceplan, ldc_svcpromise
Long li_exist, ll_selected_row
Integer li_return
String ls_filter, ls_svccod, ls_customerid, ls_currency_type
String ls_where
Long ll_row


Choose Case dwo.name
	//서비스가 바뀌었을때 해당 가격정책을 보여줌
	Case "contractmst_svccod"
		//고객의 납입자의 화폐단위 가져오기
		ls_customerid = dw_detail2.object.customerm_customerid[1] 
		select currency_type into :ls_currency_type from billinginfo bil, customerm cus
		where bil.customerid = cus.payid and  cus.customerid =:ls_customerid;
		
		ls_svccod = Trim(dw_detail2.object.contractmst_svccod[1])
		li_exist = dw_detail2.GetChild("contractmst_priceplan", ldc_priceplan)		//DDDW 구함
		If li_exist = -1 Then f_msg_usr_err(2100, Title, "GetChild() : Price Plan")
		ls_filter = "svccod = '" + ls_svccod  + "'  And  String(auth_level) >= '"  + String(gi_auth) + "' " + &
						 " And currency_type ='" + ls_currency_type + "' "
		
		ldc_priceplan.SetTransObject(SQLCA)
		li_exist =ldc_priceplan.Retrieve()
		ldc_priceplan.SetFilter(ls_filter)			//Filter정함
		ldc_priceplan.Filter()
		
		dw_detail2.object.contractmst_priceplan[1] = ""
		is_priceplan = ""
		
		If li_exist < 0 Then 				
		  f_msg_usr_err(2100, Title, "Retrieve()")
		  Return 1  		//선택 취소 focus는 그곳에
		End If
		
		dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
		If li_return < 0 Then
			Return
		End If
		
		
//가격 정책이 바뀌었을때 해당 품목을 보여줌		
	Case "contractmst_priceplan"
		is_priceplan = data
		ls_where = "det.priceplan = '" + data + "' "
		dw_detail.is_where = ls_where
		ll_row = dw_detail.Retrieve()
		If ll_row  = 0 Then
			p_save.TriggerEvent("ue_disable")
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			p_save.TriggerEvent("ue_disable")
			Return -2
		End If
		
		dw_detail2.Event ue_retrieve(ll_selected_row,li_return)
		If li_return < 0 Then
			Return
		End If
		
End Choose 
	
end event

type st_horizontal2 from w_a_reg_m_m3`st_horizontal2 within b1w_reg_chg_contractdet
integer x = 27
integer y = 676
end type

type st_horizontal from w_a_reg_m_m3`st_horizontal within b1w_reg_chg_contractdet
integer x = 27
integer y = 1348
end type

type dw_validkey from u_d_base within b1w_reg_chg_contractdet
boolean visible = false
integer x = 64
integer y = 2108
integer width = 3063
integer height = 404
integer taborder = 11
boolean bringtotop = true
string dataobject = "b1dw_inq_chg_priceplan_validkey"
end type

