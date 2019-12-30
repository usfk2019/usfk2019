$PBExportHeader$p2w_reg_partner_priceplan_v20.srw
$PBExportComments$[ssong]대리점별 가격정책 등록
forward
global type p2w_reg_partner_priceplan_v20 from w_a_reg_m_m
end type
end forward

global type p2w_reg_partner_priceplan_v20 from w_a_reg_m_m
integer width = 3131
end type
global p2w_reg_partner_priceplan_v20 p2w_reg_partner_priceplan_v20

type variables
String is_partner_yn
end variables

on p2w_reg_partner_priceplan_v20.create
call super::create
end on

on p2w_reg_partner_priceplan_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;//dw_master 조회
String ls_partner, ls_partnernm, ls_levelcod, ls_prefixno, ls_temp, ls_result[]
String ls_type, ls_fromdt, ls_todt, ls_where, ls_new, ls_close
Date ld_fromdt, ld_todt
Long ll_row 
integer li_rc, li_cnt, li_return

//dw_cond.AcceptText()
ls_partner = Trim(dw_cond.object.partner[1])
ls_partnernm = Trim(dw_cond.object.partnernm[1])
ls_levelcod = Trim(dw_cond.object.levelcod[1])
ls_prefixno = Trim(dw_cond.object.prefixno[1])


		//Null Check
		If IsNull(ls_partner) Then ls_partner = ""
		If IsNull(ls_partnernm) Then ls_partnernm = ""
		If IsNull(ls_levelcod) Then ls_levelcod = ""
		If IsNull(ls_prefixno) Then ls_prefixno = ""
		
		//Retrieve
		ls_where = ""
		IF ls_partner <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "partner like '" + ls_partner + "%' "
		End If

		IF ls_partnernm <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "Upper(partnernm) like '" + upper(ls_partnernm) + "%' "
		End If
		
		IF ls_levelcod <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "levelcod = '" + ls_levelcod + "' "
		End If
		
		IF ls_prefixno <> "" Then 
			If ls_where <> "" Then ls_where += " And "
			ls_where += "prefixno like '" + ls_prefixno + "%' "
		End If
		
		//관리대상대리점 관리여부에 따라... 2005.08.22 ohj
		If is_partner_yn = 'Y' Then	
			If ls_where <> "" Then ls_where += " And "	
			ls_where += " levelcod <= (select ref_content from sysctl1t where module = 'A1' and Ref_no = 'C100')"
		End If
		
		dw_master.is_where = ls_where
		ll_row = dw_master.Retrieve()
		
		If ll_row = 0 Then 
			f_msg_info(1000, Title, "")
		ElseIf ll_row < 0 Then
			f_msg_usr_err(2100, Title, "Retrieve()")
			Return
		End If


end event

event type integer ue_extra_insert(long al_insert_row);call super::ue_extra_insert;String ls_partner
Long ll_row

ll_row = dw_master.getselectedrow(0)
If ll_row = 0 Then Return 0 

ls_partner = Trim(dw_master.object.partner[ll_row])

IF ls_partner = "" THEN
	RETURN -1
END IF

//Insert 시 해당 row 첫번째 컬럼에 포커스
dw_detail.SetRow(al_insert_row)
dw_detail.ScrollToRow(al_insert_row)
dw_detail.SetColumn("priceplan")

//Log
dw_detail.object.partner[al_insert_row] = ls_partner
dw_detail.object.crt_user[al_insert_row] = gs_user_id
dw_detail.object.crtdt[al_insert_row] = fdt_get_dbserver_now()

RETURN 0
end event

event ue_extra_save;call super::ue_extra_save;//Save Check
String ls_partner, ls_priceplan, ls_cnt_limitflag, ls_amt_limitflag
Long ll_rows , i, ll_cnt, ll_cnt_1, ll_cnt_2

dw_detail.AcceptText()
ll_rows = dw_detail.RowCount()
If ll_rows = 0 Then Return 0

//Loop
For i=1 To ll_rows
	ls_partner = Trim(dw_detail.object.partner[i])
	ls_priceplan = Trim(dw_detail.object.priceplan[i])
	ls_cnt_limitflag = Trim(dw_detail.object.cnt_limit_flag[i])
	ls_amt_limitflag = Trim(dw_detail.object.amt_limit_flag[i])
	
	If IsNull(ls_priceplan) then ls_priceplan = ""
	If IsNull(ls_cnt_limitflag) then ls_cnt_limitflag = ""
	If IsNull(ls_amt_limitflag) then ls_amt_limitflag = ""
	
	If ls_priceplan = "" Then
		f_msg_usr_err(200, Title,"가격정책")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("priceplan")
		Return -1
	End If
	
select count(cnt_limit_flag)
  into :ll_cnt
  from partner_priceplan
 where partner =:ls_partner
   and priceplan = :ls_priceplan;


If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if

select count(amt_limit_flag)
  into :ll_cnt_1
  from partner_priceplan
 where partner =:ls_partner 
   and priceplan = :ls_priceplan;


If SQLCA.SQLCode < 0 Then	
	f_msg_sql_err(title,  " Select Error" )
	Return -2 	
End if


	
If ls_cnt_limitflag <> "" Then
	   If ls_amt_limitflag <> "" then
		f_msg_usr_err(200, Title,"한도건수 관리유형 또는 한도금액 중 한가지만 등록 가능합니다.")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("cnt_limit_flag")
		dw_detail.Object.cnt_limit_flag[i] = ""
		dw_detail.Object.amt_limit_flag[i] = ""
		Return -1
	End If
End If

/*If ls_cnt_limitflag = "" Then
	   If ls_amt_limitflag = "" then
		f_msg_usr_err(200, Title,"한도건수 관리유형 또는 한도금액 중 한가지는 등록 해야 합니다.")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("cnt_limit_flag")
		dw_detail.Object.cnt_limit_flag[i] = ""
		dw_detail.Object.amt_limit_flag[i] = ""
		Return -1
	End If
End If

   If ls_amt_limitflag <> "" then
		If ls_cnt_limitflag <> "" then
		f_msg_usr_err(200, Title,"한도건수 관리유형 또는 한도금액 중 한가지만 등록 가능합니다.")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("cnt_limit_flag")
		Return -1
	End If
End If

IF ll_cnt > 0 then
		IF ls_amt_limitflag <> "" Then
			f_msg_usr_err(201, Title, "한도건수 관리유형 또는 한도금액 중 한가지만 등록 가능합니다.")
			dw_detail.SetRow(i)
		   dw_detail.ScrollToRow(i)
		   dw_detail.SetColumn("amt_limit_flag")
			dw_detail.Object.amt_limit_flag[i] = ""
		Return -1
		end if	
elseIf ll_cnt_1 > 0 then
	if ls_cnt_limitflag <> "" then 
		f_msg_usr_err(201, Title, "한도건수 관리유형 또는 한도금액 중 한가지만 등록 가능합니다.")
		dw_detail.SetRow(i)
		dw_detail.ScrollToRow(i)
		dw_detail.SetColumn("cnt_limit_flag")
		dw_detail.Object.cnt_limit_flag[i] = ""
		Return -1
	end if
End if
//
//select count(*)
//  into :ll_cnt_2
//  from partnerused_limit
// where partner = :ls_partner
//   and priceplan = :ls_priceplan;
//
//
//If SQLCA.SQLCode < 0 Then	
//	f_msg_sql_err(title,  " Select Error" )
//	Return -2 	
//End if*/


	
	If dw_detail.GetItemStatus(i, 0, Primary!) = DataModified! THEN

   End If
	
Next

Return 0
end event

event open;call super::open;String ls_ref_desc, ls_level_code, ls_filter
Long   ll_row
DatawindowChild idc_levelcod

// 2005.08.22 ohj

//판매출고 대상 관리대상대리점 여부
ls_ref_desc = ""
is_partner_yn = fs_get_control("P0", "P002", ls_ref_desc)

//관리대상 레벨 코드 A1 C100
ls_ref_desc = ""
ls_level_code = fs_get_control("A1", "C100", ls_ref_desc)

If is_partner_yn = 'Y' Then
	
	//가격정책별일때 .. 가격정책별 item가져오기
	ll_row = dw_cond.GetChild("levelcod", idc_levelcod)
	If ll_row = -1 Then MessageBox("Error", "Not a DataWindowChild")
	
	ls_filter = "code <= '" + ls_level_code + "' "
	idc_levelcod.SetFilter(ls_filter)			//Filter정함
	idc_levelcod.Filter()
	idc_levelcod.SetTransObject(SQLCA)
	ll_row =idc_levelcod.Retrieve()
End If
end event

type dw_cond from w_a_reg_m_m`dw_cond within p2w_reg_partner_priceplan_v20
integer x = 41
integer width = 2345
integer height = 232
string dataobject = "p2dw_cnd_reg_partner_v20"
boolean hscrollbar = false
boolean vscrollbar = false
boolean livescroll = false
end type

type p_ok from w_a_reg_m_m`p_ok within p2w_reg_partner_priceplan_v20
integer x = 2464
end type

type p_close from w_a_reg_m_m`p_close within p2w_reg_partner_priceplan_v20
integer x = 2770
end type

type gb_cond from w_a_reg_m_m`gb_cond within p2w_reg_partner_priceplan_v20
integer width = 2386
integer height = 304
end type

type dw_master from w_a_reg_m_m`dw_master within p2w_reg_partner_priceplan_v20
integer y = 336
integer height = 392
string dataobject = "p2dw_inq_reg_partner_1_v20"
end type

event dw_master::ue_init();call super::ue_init;//Sort
dwObject ldwo_sort
ldwo_sort = Object.partner_t
uf_init(ldwo_sort)
end event

type dw_detail from w_a_reg_m_m`dw_detail within p2w_reg_partner_priceplan_v20
integer x = 32
integer y = 768
string dataobject = "p2dw_reg_partner_priceplan_v20"
end type

event dw_detail::constructor;call super::constructor;dw_detail.SetRowFocusIndicator(Off!)
end event

event type integer dw_detail::ue_retrieve(long al_select_row);call super::ue_retrieve;//dw_master cleck시 Retrieve
String ls_where, ls_partner
Long ll_row, i
Integer li_cnt

ls_partner = Trim(dw_master.object.partner[al_select_row])
If IsNull(ls_partner) Then ls_partner = ""
ls_where = ""

If ls_partner <> "" Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += "partner = '" + ls_partner + "'"
End If

//dw_detail 조회
dw_detail.is_where = ls_where
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return -2
End If

Return 0
end event

type p_insert from w_a_reg_m_m`p_insert within p2w_reg_partner_priceplan_v20
end type

type p_delete from w_a_reg_m_m`p_delete within p2w_reg_partner_priceplan_v20
end type

type p_save from w_a_reg_m_m`p_save within p2w_reg_partner_priceplan_v20
end type

type p_reset from w_a_reg_m_m`p_reset within p2w_reg_partner_priceplan_v20
end type

type st_horizontal from w_a_reg_m_m`st_horizontal within p2w_reg_partner_priceplan_v20
end type

