$PBExportHeader$w_a_reg_m_sql.srw
$PBExportComments$Multi master Register for SQL Process ( from w_a_condition)
forward
global type w_a_reg_m_sql from w_a_condition
end type
type p_save from u_p_save within w_a_reg_m_sql
end type
type dw_detail from u_d_sim_sql within w_a_reg_m_sql
end type
end forward

global type w_a_reg_m_sql from w_a_condition
integer height = 1924
event ue_save ( )
event type integer ue_save_sql ( )
p_save p_save
dw_detail dw_detail
end type
global w_a_reg_m_sql w_a_reg_m_sql

type variables
boolean ib_indicator = False
boolean ib_highlight = False
boolean ib_reset_saveafter = True
Integer ii_indicator
u_cust_db_app iu_mdb_app
end variables

event ue_save;Integer li_return

If dw_cond.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_cond.SetFocus()
	Return
End If

If dw_detail.AcceptText() < 1 Then
	//자료에 이상이 있다는 메세지 처리 요망 
	dw_detail.SetFocus()
	Return
End If

li_return = This.Trigger Event ue_save_sql()
Choose Case li_return
	Case Is < -2
		dw_cond.SetFocus()
	Case -2
		dw_cond.SetFocus()
	Case -1
		//ROLLBACK
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "ROLLBACK"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3010, This.Title, "Save")
	Case Is >= 0
		//COMMIT
		iu_mdb_app.is_title = This.Title
		iu_mdb_app.is_caller = "COMMIT"
		iu_mdb_app.uf_prc_db()
		If iu_mdb_app.ii_rc = -1 Then Return
		f_msg_info(3000, This.Title, "Save")
		If ib_reset_saveafter Then
			p_save.TriggerEvent("ue_disable")
			dw_detail.Reset()
		End If
End Choose

end event

on w_a_reg_m_sql.create
int iCurrent
call super::create
this.p_save=create p_save
this.dw_detail=create dw_detail
iCurrent=UpperBound(this.Control)
this.Control[iCurrent+1]=this.p_save
this.Control[iCurrent+2]=this.dw_detail
end on

on w_a_reg_m_sql.destroy
call super::destroy
destroy(this.p_save)
destroy(this.dw_detail)
end on

event open;call super::open;p_save.TriggerEvent("ue_disable")
iu_mdb_app = Create u_cust_db_app

end event

event close;call super::close;Destroy iu_mdb_app

end event

event resize;call super::resize;//2000-06-28 by kEnn
//Window 크기를 변경하면 내부의 Object의 크기 및 위치를 자동 조정
//
If sizetype = 1 Then Return

SetRedraw(False)

If newheight < dw_detail.Y Then
	dw_detail.Height = 0
Else
	dw_detail.Height = newheight - dw_detail.Y - iu_cust_w_resize.ii_dw_button_space
End If

If newwidth < dw_detail.X  Then
	dw_detail.Width = 0
Else
	dw_detail.Width = newwidth - dw_detail.X - iu_cust_w_resize.ii_dw_button_space
End If

SetRedraw(True)

end event

type dw_cond from w_a_condition`dw_cond within w_a_reg_m_sql
integer width = 2382
integer height = 312
integer taborder = 10
end type

type p_ok from w_a_condition`p_ok within w_a_reg_m_sql
integer x = 2583
integer y = 52
end type

type p_close from w_a_condition`p_close within w_a_reg_m_sql
integer x = 2583
integer y = 276
boolean originalsize = false
end type

type gb_cond from w_a_condition`gb_cond within w_a_reg_m_sql
integer width = 2441
integer height = 376
end type

type p_save from u_p_save within w_a_reg_m_sql
integer x = 2583
integer y = 164
boolean bringtotop = true
boolean originalsize = false
end type

type dw_detail from u_d_sim_sql within w_a_reg_m_sql
integer x = 32
integer y = 392
integer width = 3013
integer height = 1384
integer taborder = 20
boolean hsplitscroll = true
borderstyle borderstyle = stylebox!
end type

event retrieveend;call super::retrieveend;If rowcount > 0 Then
	p_save.TriggerEvent("ue_enable")
Else
	p_save.TriggerEvent("ue_disable")
End If

end event

