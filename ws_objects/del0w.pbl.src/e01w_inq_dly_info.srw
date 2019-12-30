$PBExportHeader$e01w_inq_dly_info.srw
$PBExportComments$[parkkh] 연체자(거래내역)조회
forward
global type e01w_inq_dly_info from w_a_inq_m_m
end type
type p_1 from u_p_delete within e01w_inq_dly_info
end type
type p_3 from u_p_reset within e01w_inq_dly_info
end type
end forward

global type e01w_inq_dly_info from w_a_inq_m_m
integer width = 3287
integer height = 2052
event ue_delete ( )
event ue_reset ( )
p_1 p_1
p_3 p_3
end type
global e01w_inq_dly_info e01w_inq_dly_info

type variables
String is_payid
String is_date

end variables

event ue_delete();Long ll_row 
string ls_payid
integer Net

Net = MessageBox("삭제확인", "삭제하면 복구가 불가능합니다. ~r)" + &
                 "연체고객 마스터에서 해당 고객을 삭제하시겠습니까?",Question!, OKCancel!, 2)
IF Net <> 1 THEN 
	return  // Process CANCEL.
END IF

ll_row = dw_master.GetSelectedrow(0)
If ll_row <= 0 Then return
ls_payid = dw_master.object.dlymst_payid[ll_row]

delete from dlymst where payid = :ls_payid;
delete from dlydet where payid = :ls_payid;
commit;
	
dw_master.RowsDiscard( ll_row, ll_row, primary! )
dw_detail.reset()
end event

event ue_reset;call super::ue_reset;dw_detail.Reset()
dw_master.Reset()
dw_cond.Reset()
dw_cond.InsertRow ( 0 )
dw_cond.SetFocus()
end event

on e01w_inq_dly_info.create
int iCurrent
call super::create
this.p_1=create p_1
this.p_3=create p_3
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_1
this.Control[iCurrent+2]=this.p_3
end on

on e01w_inq_dly_info.destroy
call super::destroy
destroy(this.p_1)
destroy(this.p_3)
end on

event ue_ok();call super::ue_ok;String ls_where
String ls_payid , ls_name , ls_status, ls_workdt, ls_temp, ls_ref_desc
Long   ll_tmp, ll_row
Integer li_delay_months, li_delay_months_to

ls_payid = trim( dw_cond.Object.payid[1] )
ls_name = trim( dw_cond.Object.name[1] )
ls_status = trim( dw_cond.object.status_cd[1] )
ls_workdt = Trim( string(dw_cond.Object.work_date[1],'yyyymmdd') )

li_delay_months =  dw_cond.Object.delay_months[1]
If li_delay_months = 0 Then SetNull(li_delay_months)
li_delay_months_to = dw_cond.Object.delay_months_to[1]
If li_delay_months_to = 0 Then SetNull(li_delay_months_to)

////연체대상자 마지막 추출일
//Select ref_content
//Into :is_date
//From sysctl1t
//Where module = 'E1' And ref_no = 'A1';
ls_temp = fs_get_control("E2", "A101", ls_ref_desc)
If IsNull(ls_temp) Then Return
is_date = ls_temp

if not isnull( ls_workdt )  and ls_workdt <> '' then
	If Not Isdate( MidA(ls_workdt,1,4) + "/" + MidA(ls_workdt,5,2) + "/" + MidA(ls_workdt,7,2) ) Then
		MessageBox( "알림", "올바른 년월이 아닙니다. " )
		dw_cond.Setcolumn( 4 )
		dw_cond.Setfocus()
		return
	end If
end if

If ls_payid <> '' then
	ls_where += " dlymst.payid = '" + ls_payid + "' "
end If	

If ls_name <> '' Then
	If ls_where <> '' then ls_where += " and "
	ls_where += " cus.customernm like '%"+ ls_name + "%' "
end If

If ls_status <> '' Then
	If ls_where <> '' then ls_where += " and " 
	ls_where += " dlymst.status = '" + ls_status + "' "
end If

If ls_workdt <> '' Then
	If ls_where <> '' then ls_where += " and " 
	ls_where += " to_char(dlymst.first_date,'yyyymmdd') = '" + ls_workdt + "' "
end If

If Not IsNull(li_delay_months) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS >= " + String(li_delay_months) + " " 
End If
If Not IsNull(li_delay_months_to) Then
	If ls_where <> "" then ls_where += " and " 
	ls_where += " dlymst.DELAY_MONTHS <= " + String(li_delay_months_to) + " " 
End If

dw_master.is_where = ls_where
ll_row = dw_master.Retrieve()
If ll_row < 0 Then 
	f_msg_usr_err(2100, Title, "Retrieve()")
	Return
ElseIf ll_row = 0 Then
	f_msg_usr_err(1100, Title, "")
	Return
End If
end event

type dw_cond from w_a_inq_m_m`dw_cond within e01w_inq_dly_info
integer x = 37
integer y = 40
integer width = 1829
integer height = 268
integer taborder = 20
string dataobject = "e01d_cnd_inq_dly_info"
boolean hscrollbar = false
boolean vscrollbar = false
end type

type p_ok from w_a_inq_m_m`p_ok within e01w_inq_dly_info
integer x = 1938
boolean originalsize = false
end type

type p_close from w_a_inq_m_m`p_close within e01w_inq_dly_info
integer x = 2903
boolean originalsize = false
end type

type gb_cond from w_a_inq_m_m`gb_cond within e01w_inq_dly_info
integer width = 1865
integer height = 328
end type

type dw_master from w_a_inq_m_m`dw_master within e01w_inq_dly_info
integer x = 23
integer y = 356
integer width = 3186
integer height = 536
integer taborder = 30
string dataobject = "e01d_inq_dly_info_master"
end type

event dw_master::constructor;call super::constructor;dwObject ldwo_sort

ldwo_sort = This.Object.dlymst_payid_t

uf_init(ldwo_sort)

end event

type dw_detail from w_a_inq_m_m`dw_detail within e01w_inq_dly_info
integer x = 23
integer y = 924
integer width = 3186
integer height = 984
integer taborder = 10
string dataobject = "e01d_inq_dly_info_detail"
end type

event type integer dw_detail::ue_retrieve(long al_select_row);Long ll_rc
String ls_where
string ls_payid

if al_select_row > 0 then
	ls_payid = dw_master.Object.dlymst_payid[al_select_row]
else 
	ls_payid = ''
End If

is_payid = ls_payid  

ls_where = " reqdtl.payid = '" + ls_payid + "' "
If is_date <> "" Or Not IsNull(is_date) Then
	If ls_where <> "" Then ls_where += " And "
	ls_where += " to_char(reqdtl.trdt,'yyyymmdd') <= '" + is_date +"' " 
End If

//ls_where += " and dlystscod.status_flag  = '1' "  

is_where = ls_where
ll_rc = Retrieve()

Return ll_rc
end event

type st_horizontal from w_a_inq_m_m`st_horizontal within e01w_inq_dly_info
integer y = 892
end type

type p_1 from u_p_delete within e01w_inq_dly_info
integer x = 2583
integer y = 52
boolean originalsize = false
end type

type p_3 from u_p_reset within e01w_inq_dly_info
integer x = 2258
integer y = 52
boolean originalsize = false
end type

