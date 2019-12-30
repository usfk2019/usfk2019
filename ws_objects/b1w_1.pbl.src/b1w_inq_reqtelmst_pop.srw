$PBExportHeader$b1w_inq_reqtelmst_pop.srw
forward
global type b1w_inq_reqtelmst_pop from b1w_inq_reqtelmst
end type
end forward

global type b1w_inq_reqtelmst_pop from b1w_inq_reqtelmst
integer width = 3099
integer height = 1540
boolean maxbox = false
boolean resizable = false
windowtype windowtype = popup!
windowstate windowstate = normal!
end type
global b1w_inq_reqtelmst_pop b1w_inq_reqtelmst_pop

on b1w_inq_reqtelmst_pop.create
call super::create
end on

on b1w_inq_reqtelmst_pop.destroy
call super::destroy
end on

event open;call super::open;String ls_seq, ls_where
Long ll_rows
f_center_window(This)

//수정 불가능
ls_seq = iu_cust_msg.is_data[1]

ls_where = ""

If ls_where <> "" Then ls_where += " And "

If ls_seq <> "" Then
	ls_where += " to_char(prcseq) = '" + ls_seq + "' "
End If
	
dw_detail.is_where = ls_where
ll_rows = dw_detail.Retrieve()
If ll_rows = 0 Then
	f_msg_info(1000, Title, "")
ElseIf ll_rows < 0 Then
	f_msg_usr_err(2100, Title, "")
	Return
End If


end event

type dw_cond from b1w_inq_reqtelmst`dw_cond within b1w_inq_reqtelmst_pop
boolean visible = false
end type

type p_ok from b1w_inq_reqtelmst`p_ok within b1w_inq_reqtelmst_pop
boolean visible = false
end type

type p_close from b1w_inq_reqtelmst`p_close within b1w_inq_reqtelmst_pop
integer x = 2752
integer y = 48
end type

type gb_cond from b1w_inq_reqtelmst`gb_cond within b1w_inq_reqtelmst_pop
boolean visible = false
end type

type dw_detail from b1w_inq_reqtelmst`dw_detail within b1w_inq_reqtelmst_pop
integer x = 18
integer y = 176
integer height = 1176
end type

