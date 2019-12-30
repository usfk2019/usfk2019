$PBExportHeader$b1w_validkey_update_popup_2_cl_1k.srw
$PBExportComments$[islim] 인증 Key 추가(제너)
forward
global type b1w_validkey_update_popup_2_cl_1k from b1w_validkey_update_popup_2_cl
end type
end forward

global type b1w_validkey_update_popup_2_cl_1k from b1w_validkey_update_popup_2_cl
end type
global b1w_validkey_update_popup_2_cl_1k b1w_validkey_update_popup_2_cl_1k

on b1w_validkey_update_popup_2_cl_1k.create
call super::create
end on

on b1w_validkey_update_popup_2_cl_1k.destroy
call super::destroy
end on

event open;/*------------------------------------------------------------------------
	Nmae	: b1w_validkey_update_popup_2
	Desc	: 인증KEY 추가
	Ver	: 	1.0
	Date	: 	2003.02.05
	Programer : Park Kyung Hae(parkkh)
-------------------------------------------------------------------------*/
String ls_customerid, ls_customernm, ls_ref_desc, ls_temp, ls_result[]
Long ll_i

Call w_base::Open

f_center_window(b1w_validkey_update_popup_2_cl_1k)

//iu_cust_msg.is_data[1] = ls_itemcod	     //itemcod
//iu_cust_msg.is_data[2] = gs_pgm_id[gi_open_win_no]		//프로그램 ID
//iu_cust_msg.is_data[3] = ls_contractseq      //계약SEQ
//iu_cust_msg.is_data[4] = ls_svctype      //서비스타입
//iu_cust_msg.is_data[5] = is_status       //개통상태 코드
//iu_cust_msg.is_data[6] = ls_svccod       //서비스코드

iu_cust_msg = Message.PowerObjectParm
is_itemcod = iu_cust_msg.is_data[1]
is_pgm_id = iu_cust_msg.is_data[2]
is_contractseq = iu_cust_msg.is_data[3]
is_svctype = iu_cust_msg.is_data[4]
is_status = iu_cust_msg.is_data[5]
is_svccod = iu_cust_msg.is_data[6]

ls_ref_desc = ""
ls_temp = fs_get_control("B1", "P203", ls_ref_desc)
If ls_temp = "" Then Return
fi_cut_string(ls_temp, ";" , is_Xener_svccod[])   //Xener GateKeeper 연동 svccode

is_svctype_post = fs_get_control("B0", "P102", ls_ref_desc)   //후불서비스타입
is_svctype_pre = fs_get_control("B0", "P101", ls_ref_desc)    //선불서비스타입

is_xener_svc = 'N'
For ll_i = 1  to UpperBound(is_Xener_svccod)
	IF is_svccod = is_Xener_svccod[ll_i] Then
		is_xener_svc = 'Y'
		Exit
	End IF
NEXT	

If is_svctype = "" Then
	f_msg_info(9000, Title, "해당 서비스에 서비스 유형이 없습니다. 확인요망!!")
	Return
End If

IF is_svctype = is_svctype_post Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_2_cl"
	dw_detail.SetTransObject(SQLCA)
Elseif is_svctype = is_svctype_pre Then
	dw_detail.dataObject = "b1dw_validkey_update_popup_2_pre_cl"
	dw_detail.SetTransObject(SQLCA)	
End If

If is_contractseq <> "" Then
	Post Event ue_ok()
End If
end event

event type integer ue_save();Long ll_row
Integer li_rc
b1u_dbmgr4 	lu_dbmgr
String ls_validitem3_t, ls_h323id

dw_detail.Accepttext()

ll_row  = dw_detail.RowCount()
If ll_row = 0 Then Return 0

ls_h323id = Trim(dw_detail.object.new_h323id[1])
If IsNull(ls_h323id) Then ls_h323id = ""							

ls_validitem3_t = Trim(String(dw_detail.object.validitem3_t.text))		
If ls_validitem3_t = "착신지번호"  Then
	If	ls_h323id = "" Then
		f_msg_info(200, Title, "착신지번호")
		dw_detail.SetRow(1)
		dw_detail.ScrollToRow(1)		
		dw_detail.SetColumn("new_h323id")
		Return -1
	End If
End If


If ls_validitem3_t = "접속번호"  Then
	If ls_h323id = "" Then
		f_msg_info(200, Title, "접속번호")
		dw_detail.SetRow(1)
		dw_detail.ScrollToRow(1)
		dw_detail.SetColumn("new_h323id")
		Return -1
	End If
End If


//저장
lu_dbmgr = Create b1u_dbmgr4
lu_dbmgr.is_caller = "b1w_validkey_update_popup_2_cl%ue_save"
lu_dbmgr.is_title = Title
lu_dbmgr.idw_data[1] = dw_detail
lu_dbmgr.is_data[1]  = is_itemcod
lu_dbmgr.is_data[2]  = is_contractseq
lu_dbmgr.is_data[3]  = is_svctype
lu_dbmgr.is_data[4]  = is_pgm_id
lu_dbmgr.is_data[5]  = is_xener_svc   	 //제너서비스여부('Y'/'N')
lu_dbmgr.is_data[6]  = is_status

lu_dbmgr.uf_prc_db_04()
li_rc = lu_dbmgr.ii_rc

If li_rc = -1 Then
	Destroy lu_dbmgr
	Return -1
End If

Destroy lu_dbmgr

P_save.TriggerEvent("ue_disable")
dw_detail.enabled = False

Return 0
end event

type p_save from b1w_validkey_update_popup_2_cl`p_save within b1w_validkey_update_popup_2_cl_1k
end type

type p_close from b1w_validkey_update_popup_2_cl`p_close within b1w_validkey_update_popup_2_cl_1k
end type

type dw_detail from b1w_validkey_update_popup_2_cl`dw_detail within b1w_validkey_update_popup_2_cl_1k
end type

event dw_detail::retrieveend;call super::retrieveend;String ls_svccod
long ll_i

ll_i=dw_detail.rowcount()

ls_svccod=LeftA(is_svccod, 2)

If ll_i = 1 Then
	If ls_svccod= "X2" Then			//로밍플라이-랜드서비스
		dw_detail.object.validitem3_t.text="접속번호"
		dw_detail.object.t_6.text=""
	ElseIf ls_svccod= "X3"	Then		//로밍플라이-모바일
		dw_detail.object.validitem3_t.text="착신지번호"
		dw_detail.object.t_6.text=""
	End If
Else
	return -1
End If

end event

type ln_2 from b1w_validkey_update_popup_2_cl`ln_2 within b1w_validkey_update_popup_2_cl_1k
end type

