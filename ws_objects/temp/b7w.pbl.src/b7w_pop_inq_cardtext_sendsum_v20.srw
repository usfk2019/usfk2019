$PBExportHeader$b7w_pop_inq_cardtext_sendsum_v20.srw
$PBExportComments$[jsha] 카드쳥구요청 결과 popup window
forward
global type b7w_pop_inq_cardtext_sendsum_v20 from w_a_inq_m
end type
end forward

global type b7w_pop_inq_cardtext_sendsum_v20 from w_a_inq_m
integer width = 3483
integer height = 1068
boolean minbox = false
boolean maxbox = false
windowtype windowtype = popup!
windowstate windowstate = normal!
end type
global b7w_pop_inq_cardtext_sendsum_v20 b7w_pop_inq_cardtext_sendsum_v20

type variables
String is_filename
end variables

on b7w_pop_inq_cardtext_sendsum_v20.create
call super::create
end on

on b7w_pop_inq_cardtext_sendsum_v20.destroy
call super::destroy
end on

event ue_ok();call super::ue_ok;String ls_where
Long ll_row

ls_where = " file_name = '" + is_filename + "' "
ll_row = dw_detail.Retrieve()

If ll_row < 0 Then
	f_msg_usr_err(2100, This.Title, "Retrieve()")
End IF
end event

event open;call super::open;f_center_window(b7w_pop_inq_cardtext_sendsum_v20)

iu_cust_msg = Message.PowerObjectParm
is_filename = iu_cust_msg.is_data[1]

If is_filename <> "" Then
	This.TriggerEvent('ue_ok')
End If
end event

type dw_cond from w_a_inq_m`dw_cond within b7w_pop_inq_cardtext_sendsum_v20
boolean visible = false
end type

type p_ok from w_a_inq_m`p_ok within b7w_pop_inq_cardtext_sendsum_v20
boolean visible = false
end type

type p_close from w_a_inq_m`p_close within b7w_pop_inq_cardtext_sendsum_v20
boolean visible = false
integer x = 23
integer y = 560
end type

type gb_cond from w_a_inq_m`gb_cond within b7w_pop_inq_cardtext_sendsum_v20
boolean visible = false
end type

type dw_detail from w_a_inq_m`dw_detail within b7w_pop_inq_cardtext_sendsum_v20
integer x = 0
integer y = 12
integer width = 3397
integer height = 920
string dataobject = "b7dw_pop_inq_cardtext_sendsum_v20"
boolean ib_sort_use = false
end type

