$PBExportHeader$b2w_reg_partnerused_limit2_v20.srw
$PBExportComments$[ssong]대리점 사용한도 관리(금액)
forward
global type b2w_reg_partnerused_limit2_v20 from w_a_reg_m_m
end type
end forward

global type b2w_reg_partnerused_limit2_v20 from w_a_reg_m_m
integer width = 3191
integer height = 1964
end type
global b2w_reg_partnerused_limit2_v20 b2w_reg_partnerused_limit2_v20

type variables
String is_partner, is_partner_1, is_limit_flag
end variables

forward prototypes
public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col)
end prototypes

public function integer wf_dropdownlist (readonly datawindow adw_obj, long al_row, string as_col);String ls_SiteCode, ls_Doc_D1, ls_sql

dataWindowChild	dwc_child
adw_obj.GetChild (as_col, dwc_child)

dwc_child.SetTransObject (SQLCA)

adw_obj.Accepttext()

Choose Case lower(as_col)
	Case "priceplan"  	
		ls_sql  = "        select a.partner														" + &
					 "					, a.priceplan				                           " + &
					 "             , b.priceplan_desc						               " + &
					 "              from (  select Distinct 'ALL' PARTNER             " + &
					 "                           , 'ALL' PRICEPLAN                    " + &
					 "                           , '2' sort                           " + &
					 "                        from PARTNER_PRICEPLAN                  " + &
					 "                   union all                                    " + &
					 "                    	select PARTNER                            " + &
					 "                           , PRICEPLAN                          " + &
					 "                           , '1' sort                           " + &
					 "                        from PARTNER_PRICEPLAN						" + &
					 "							    where partner = '" + is_partner_1 + "'	" + &
					 "							      and amt_limit_flag like 'Y%') a 			" + &
					 "                 , (  select Distinct 'ALL' priceplan           " + &
					 "									  ,  'ALL' priceplan_desc					" + &
					 "								  from priceplanmst								" + &
					 "							union all												" + &
					 "								select priceplan									" + &
					 "									  , priceplan_desc							" + &
					 "								  from priceplanmst) b							" + &
					 "        		where a.priceplan = b.priceplan	                  " + &
					 "          ORDER BY a.sort           ASC                         "
					 
		 

End Choose

If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)

dwc_child.Retrieve ()
//adw_obj.uf_MatchDDDW (as_col)


Return 0


end function

on b2w_reg_partnerused_limit2_v20.create
call super::create
end on

on b2w_reg_partnerused_limit2_v20.destroy
call super::destroy
end on

event ue_ok;call super::ue_ok;String	ls_where
Long		ll_rows
String	ls_partner

ls_partner	= Trim(dw_cond.Object.partner[1])

IF( IsNull(ls_partner) ) THEN ls_partner = ""

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return
End If

//Dynamic SQL
IF ls_partner <> "" THEN	
	IF ls_where <> "" THEN ls_where += " AND "
	ls_where += "partner = '" + ls_partner + "' "
END IF

IF ls_where <> "" THEN ls_where += " AND "
ls_where += "limit_flag = '" + is_limit_flag + "' "


dw_master.is_where	= ls_where
ll_rows = dw_master.Retrieve()

IF ll_rows < 0 THEN
	f_msg_usr_err(2100, Title, "Retrive")
ELSEIF ll_rows = 0 THEN
	f_msg_info(1000, Title, "")
END IF

p_save.TriggerEvent("ue_enable")

end event

event ue_extra_save;call super::ue_extra_save;String ls_where
Long ll_row, ll_limitbal_qty, ll_cnt, ll_cnt_1, ll_cnt_2, ll_cnt_3
String ls_partner, ls_priceplan, ls_worktype, ls_remark, ls_plusminus
Integer li_return, li_ret, li_rc
Dec{2} lc_quota

dw_cond.AcceptText()

ls_partner   = fs_snvl(dw_cond.Object.partner[1], '')
ls_priceplan = fs_snvl(dw_cond.Object.priceplan[1], '')
ls_worktype  = fs_snvl(dw_cond.Object.worktype[1], '')
ls_remark    = fs_snvl(dw_cond.Object.remark[1], '')
ls_plusminus = fs_snvl(dw_cond.Object.plmi[1], '')

lc_quota     = dw_cond.Object.quota[1]
If IsNull(lc_quota) Then lc_quota = 0

If ls_partner = "" Then
	f_msg_usr_err(200, Title, "대리점")
	dw_cond.SetFocus()
	dw_cond.SetColumn("partner")
	Return -2
End If

If ls_priceplan = "" Then
	f_msg_usr_err(200, Title, "가격정책")
	dw_cond.SetFocus()
	dw_cond.SetColumn("priceplan")
	Return -2
End If

If ls_worktype = "" Then
	f_msg_usr_err(200, Title, "유형")
	dw_cond.SetFocus()
	dw_cond.SetColumn("worktype")
	Return -2
End If
//
//If lc_quota = 0 Then
//	f_msg_usr_err(200, Title, "할당")
//	dw_cond.SetFocus()
//	dw_cond.SetColumn("quota")
//	Return -1
//End If
//
If lc_quota <= 0 Then
	f_msg_usr_err(201, Title, "할당량은 0보다 커야 합니다.")
	dw_cond.SetFocus()
	dw_cond.SetColumn("quota")
	Return -2
End If

select limitbal_qty
  into :ll_limitbal_qty
  from partnerused_limit
 where partner   = :ls_partner
   and priceplan = :ls_priceplan;

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  "Select Error partnerused_limit" )
	Return -2 
elseif SQLCA.SQLCode =100 Then
	ll_limitbal_qty = 0
End If
	
IF ls_plusminus = "1" THEN
	if lc_quota > ll_limitbal_qty then
		f_msg_usr_err(201, Title, "사용한도가 부족합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("quota")
		Return -2
	End If
	
	lc_quota = lc_quota * -1
END IF

//all 가격정책 cont
select count(priceplan)
  into :ll_cnt
  from partnerused_limit
 where priceplan = 'ALL'
   and partner   = :ls_partner
	and limit_flag = :is_limit_flag;

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if

//all 가격정책 cont
select count(priceplan)
  into :ll_cnt_2
  from partnerused_limit
 where priceplan = 'ALL'
   and partner   = :ls_partner
	and limit_flag <> :is_limit_flag;

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if

//파트너 
select count(priceplan)
  into :ll_cnt_1
  from partnerused_limit
 where partner    = :ls_partner
   and priceplan <> 'ALL'
	and limit_flag = :is_limit_flag;

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if

select count(priceplan)
  into :ll_cnt_3
  from partnerused_limit
 where partner    = :ls_partner
   and priceplan <> 'ALL'
	and limit_flag <> :is_limit_flag;

If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if

if ll_cnt_2 = 0 then
	If ls_priceplan = 'ALL' then
		IF ll_cnt_3 >= 1 Then
			f_msg_usr_err(201, Title, "'사용한도(건수)' 등록되어 있어 ALL 가격정책을 등록할수 없습니다. ")
			dw_cond.SetFocus()
			dw_cond.SetColumn("priceplan")
			Return -2
	   End If
	End if
elseif ll_cnt_2 > 0 then
		f_msg_usr_err(201, Title, "'사용한도(건수)'에 ALL 가격정책이 등록되어 있어 가격정책을 등록할수 없습니다.")
		dw_cond.object.partner[1] = ""
		dw_cond.object.priceplan[1] = ""
		dw_cond.object.worktype[1] = ""
		dw_cond.object.quota[1] = 0
		dw_cond.object.remark[1] = ""
		dw_cond.SetFocus()
		dw_cond.SetColumn("partner")
		Return -2
		end if
if ll_cnt = 0 then
	if ls_priceplan = 'ALL' then 
		IF ll_cnt_1 >= 1 Then
			f_msg_usr_err(201, Title, "'ALL' 가격정책은 선택할수 없습니다.")
			dw_cond.SetFocus()
			dw_cond.SetColumn("priceplan")
			Return -2
		end if	
	End If
elseIf ll_cnt > 0 then
	if ls_priceplan <>  'ALL' then 
		f_msg_usr_err(201, Title, "'ALL' 가격정책만 선택 가능합니다.")
		dw_cond.SetFocus()
		dw_cond.SetColumn("priceplan")
		Return -2
	end if

End If
	
//***** 처리부분 *****
b2u_dbmgr iu_db

iu_db = Create b2u_dbmgr
iu_db.is_title = Title

iu_db.is_data[1] = ls_partner	      //대리점
iu_db.is_data[2] = ls_priceplan		//가격정책
iu_db.is_data[3] = ls_worktype		//유형
iu_db.is_data[4] = ls_remark	   	//비고
iu_db.is_data[5] = gs_user_id
iu_db.is_data[6] = is_partner       //본사
iu_db.is_data[7] = is_limit_flag		//limit_flag = 'Y1A'
iu_db.ic_data[1] = lc_quota		   //할당금액

//iu_db.idw_data[1] = dw_detail

iu_db.uf_prc_db_04()
li_rc	= iu_db.ii_rc

Destroy iu_db
Return li_rc

end event

event open;call super::open;String ls_ref_desc

p_save.TriggerEvent("ue_enable")
is_partner = fs_get_control("A1", "C102", ls_ref_desc)

is_limit_flag = fs_get_control("A1", "C723", ls_ref_desc)

//is_limit_flag = 'A'


//dw_cond.Object.priceplan[1] = ""

dw_cond.object.priceplan.Protect = 1
dw_cond.object.worktype.Protect = 1
dw_cond.object.quota.Protect = 1
dw_cond.object.remark.Protect = 1
dw_cond.object.plmi.Protect = 1

end event

event resize;call super::resize;
SetRedraw(False)

If newheight < (dw_detail.Y + iu_cust_w_resize.ii_button_space) Then
	
		p_save.Y    = p_ok.Y
	
Else

		p_save.Y    = p_ok.Y
End If


SetRedraw(True)
end event

event ue_save;Integer li_return
String ls_partner, ls_where
Dec{2} lc_tot_credit, lc_tot_samt, lc_tot_balance

If dw_cond.AcceptText() < 1 Then//???
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return -1
End If


li_return = This.Trigger Event ue_extra_save()

Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		
		//ROLLBACK
		iu_cust_db_app.is_title = This.Title
		iu_cust_db_app.is_caller = "ROLLBACK"
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then Return -1
		f_msg_info(3010, This.Title, "대리점사용한도관리처리")
	Case Is >= 0
		//COMMIT
		iu_cust_db_app.is_title = This.Title
		iu_cust_db_app.is_caller = "COMMIT"
		iu_cust_db_app.uf_prc_db()
		If iu_cust_db_app.ii_rc = -1 Then Return -1
		f_msg_info(3000, This.Title, "대리점사용한도관리 처리완료")
		//If ib_reset_saveafter Then
			//p_save.TriggerEvent("ue_disable")
			//dw_detail.Reset()
			Trigger event ue_ok()
			//dw_master.Retrieve()
			//dw_detail.Retrieve()
		//end if
End Choose

return 0


end event

type dw_cond from w_a_reg_m_m`dw_cond within b2w_reg_partnerused_limit2_v20
event dropdownlist pbm_dwndropdown
integer y = 40
integer width = 1765
integer height = 668
string dataobject = "b2dw_cnd_reg_partnerused_limit1_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

event dw_cond::clicked;call super::clicked;////messagebox('','2')
////wf_dropdownlist(This, 1, This.GetColumnName())
//string ls_col
//String ls_SiteCode, ls_Doc_D1, ls_sql
//
//dw_cond.ACCEPTTEXT()
//
//ls_col = DW_COND.GetColumnName()
//IF ls_col <> 'partner' Then
//is_partner_1 = fs_snvl(dw_cond.Object.partner[1], '')
//
//if is_partner_1 = '' then
//	messagebox('','파트너 선태해라.')   
//	return -1
//end if
//End if
//messagebox('','3')
//
//MESSAGEBOX('', ls_col)
////wf_dropdownlist(DW_COND, 1, DW_COND.GetColumnName())
//
//dataWindowChild	dwc_child
//dw_cond.GetChild(ls_col, dwc_child)
//
//dwc_child.SetTransObject (SQLCA)
//
//messagebox('', is_partner_1)
//
//Choose Case lower(ls_col)
//	Case "priceplan"   	
//		messagebox('', is_partner_1)
//			ls_sql  = "        select a.PARTNER                                        " + &
//						 "             , a.PRICEPLAN                                      " + &
//						 "             , b.PRICEPLAN_DESC                                 " + &
//						 "              from (  select Distinct 'ALL' PARTNER             " + &
//						 "                         , 'ALL' PRICEPLAN                      " + &
//						 "                         , '2' sort                             " + &
//						 "                      from PARTNER_PRICEPLAN                    " + &
//						 "                    union all                                   " + &
//						 "                    select PARTNER                              " + &
//						 "                         , PRICEPLAN                            " + &
//						 "                         , '1' sort                             " + &
//						 "                      from PARTNER_PRICEPLAN							" + &
//						 "							  where a.partner = '" + is_partner_1 + "')a " + &
//						 "                   , priceplanmst b                             " + &
//						 "        where a.priceplan = b.priceplan                         " + &
//						 "        ORDER BY a.sort ASC                                     "
//					  
//					  
//		 messagebox('', ls_sql)
//
//End Choose
//
//If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)
//
//dwc_child.Retrieve ()
////dw_cond.uf_MatchDDDW (as_col)
//
//Return 0
end event

event dw_cond::itemchanged;call super::itemchanged;String ls_col, ls_partner

ls_col = dw_cond.GetColumnName()



Choose Case Lower(ls_col)
	case "partner"
		is_partner_1 = fs_snvl(dw_cond.Object.partner[1], '')
		dw_cond.Object.priceplan[1] = ''
		dw_cond.Object.worktype[1] = ''
		dw_cond.Object.quota[1] = 0
		dw_cond.Object.plmi[1] = '0'
		dw_cond.Object.remark[1] = ''
		dw_cond.object.priceplan.Protect = 0
      dw_cond.object.worktype.Protect = 0
      dw_cond.object.quota.Protect = 0
      dw_cond.object.remark.Protect = 0
      dw_cond.object.plmi.Protect = 0
		dw_master.reset()
		dw_detail.reset()
		wf_dropdownlist(This, 1, "priceplan")
		p_ok.TriggerEvent("ue_enable")

	Case "priceplan"
		
		ls_partner = Trim(dw_cond.Object.partner[1])
		IF( IsNull(ls_partner) ) THEN ls_partner = ""
		
		If ls_partner = "" Then
			f_msg_usr_err(200, Title, "대리점을 먼저 선택 하십시오")
			dw_cond.Object.priceplan[1] = ""
			dw_cond.SetFocus()
			dw_cond.SetColumn("partner")  
			Return -1
		End If
		
End Choose

Return 0



//Choose Case lower(ls_col)
//	Case "priceplan"   	
//		messagebox('', is_partner_1)
//			ls_sql  = "        select a.PARTNER                                        " + &
//						 "             , a.PRICEPLAN                                      " + &
//						 "             , b.PRICEPLAN_DESC                                 " + &
//						 "              from (  select Distinct 'ALL' PARTNER             " + &
//						 "                         , 'ALL' PRICEPLAN                      " + &
//						 "                         , '2' sort                             " + &
//						 "                      from PARTNER_PRICEPLAN                    " + &
//						 "                    union all                                   " + &
//						 "                    select PARTNER                              " + &
//						 "                         , PRICEPLAN                            " + &
//						 "                         , '1' sort                             " + &
//						 "                      from PARTNER_PRICEPLAN							" + &
//						 "							  where a.partner = '" + is_partner_1 + "')a " + &
//						 "                   , priceplanmst b                             " + &
//						 "        where a.priceplan = b.priceplan                         " + &
//						 "        ORDER BY a.sort ASC                                     "
//					  
//					  
//		 messagebox('', ls_sql)
//
//End Choose
//
//If ls_sql <> "" Then dwc_child.SetSQLSelect(ls_sql)
//
//dwc_child.Retrieve ()
////dw_cond.uf_MatchDDDW (as_col)
//
//Return 0
end event

type p_ok from w_a_reg_m_m`p_ok within b2w_reg_partnerused_limit2_v20
integer x = 2011
integer y = 52
end type

type p_close from w_a_reg_m_m`p_close within b2w_reg_partnerused_limit2_v20
integer x = 2629
integer y = 52
boolean originalsize = false
end type

type gb_cond from w_a_reg_m_m`gb_cond within b2w_reg_partnerused_limit2_v20
integer width = 1883
integer height = 724
end type

type dw_master from w_a_reg_m_m`dw_master within b2w_reg_partnerused_limit2_v20
integer x = 9
integer y = 748
integer width = 3109
integer height = 492
string dataobject = "b2dw_reg_mst_partnerused_limit_v20"
end type

event dw_master::ue_init;call super::ue_init;dwObject ldwo_sort
ldwo_sort = Object.priceplan_t
uf_init(ldwo_sort)
end event

event dw_master::retrieveend;call super::retrieveend;dw_cond.Enabled = True
end event

type dw_detail from w_a_reg_m_m`dw_detail within b2w_reg_partnerused_limit2_v20
integer x = 9
integer y = 1284
integer width = 3109
integer height = 532
string dataobject = "b2dw_reg_det_partnerused_limit_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)

end event

event dw_detail::ue_retrieve;call super::ue_retrieve;String ls_partner,ls_priceplan 
String ls_where
Long ll_row

ls_partner = Trim(dw_master.Object.partner[al_select_row])
ls_priceplan = Trim(dw_master.Object.priceplan[al_select_row])


If al_select_row > 0 Then
	ls_where = "partner = '" + ls_partner + "' AND priceplan = '" + ls_priceplan +"' "
	dw_detail.is_where = ls_where		
	ll_row = dw_detail.Retrieve()	
	If ll_row < 0 Then
		f_msg_usr_err(2100, Parent.Title, "Retrieve()")
		Return -1
	ElseIf ll_row = 0 Then
		//Return 1
	End If
End if

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within b2w_reg_partnerused_limit2_v20
boolean visible = false
integer x = 23
integer y = 1708
end type

type p_delete from w_a_reg_m_m`p_delete within b2w_reg_partnerused_limit2_v20
boolean visible = false
integer x = 315
integer y = 1708
end type

type p_save from w_a_reg_m_m`p_save within b2w_reg_partnerused_limit2_v20
integer x = 2322
integer y = 52
boolean enabled = true
end type

type p_reset from w_a_reg_m_m`p_reset within b2w_reg_partnerused_limit2_v20
boolean visible = false
integer x = 1339
integer y = 1708
boolean enabled = true
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within b2w_reg_partnerused_limit2_v20
integer x = 9
integer y = 1244
end type

