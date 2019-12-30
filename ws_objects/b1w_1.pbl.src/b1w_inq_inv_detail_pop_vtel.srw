$PBExportHeader$b1w_inq_inv_detail_pop_vtel.srw
forward
global type b1w_inq_inv_detail_pop_vtel from b1w_inq_inv_detail_vtel
end type
end forward

global type b1w_inq_inv_detail_pop_vtel from b1w_inq_inv_detail_vtel
end type
global b1w_inq_inv_detail_pop_vtel b1w_inq_inv_detail_pop_vtel

on b1w_inq_inv_detail_pop_vtel.create
int iCurrent
call super::create
end on

on b1w_inq_inv_detail_pop_vtel.destroy
call super::destroy
end on

event open;call super::open;f_center_window(This)

//수정 불가능
dw_cond.object.value[1] = "customerid"
dw_cond.object.name[1] = iu_cust_msg.is_data[1]

//Item Changed Event 발생
Trigger Event ue_ok()
end event

type dw_cond from b1w_inq_inv_detail_vtel`dw_cond within b1w_inq_inv_detail_pop_vtel
end type

type p_ok from b1w_inq_inv_detail_vtel`p_ok within b1w_inq_inv_detail_pop_vtel
end type

type p_close from b1w_inq_inv_detail_vtel`p_close within b1w_inq_inv_detail_pop_vtel
end type

type gb_cond from b1w_inq_inv_detail_vtel`gb_cond within b1w_inq_inv_detail_pop_vtel
end type

type dw_master from b1w_inq_inv_detail_vtel`dw_master within b1w_inq_inv_detail_pop_vtel
end type

type tab_1 from b1w_inq_inv_detail_vtel`tab_1 within b1w_inq_inv_detail_pop_vtel
end type

type st_horizontal from b1w_inq_inv_detail_vtel`st_horizontal within b1w_inq_inv_detail_pop_vtel
end type

type dw_cond2 from b1w_inq_inv_detail_vtel`dw_cond2 within b1w_inq_inv_detail_pop_vtel
end type

type p_find from b1w_inq_inv_detail_vtel`p_find within b1w_inq_inv_detail_pop_vtel
end type

type p_saveas from b1w_inq_inv_detail_vtel`p_saveas within b1w_inq_inv_detail_pop_vtel
end type

