$PBExportHeader$rpt0u_dbmgr.sru
$PBExportComments$[parkkh] Daily Report - DB 접속
forward
global type rpt0u_dbmgr from u_cust_a_db
end type
end forward

global type rpt0u_dbmgr from u_cust_a_db
end type
global rpt0u_dbmgr rpt0u_dbmgr

forward prototypes
public subroutine uf_prc_db ()
public subroutine uf_prc_db_01 ()
end prototypes

public subroutine uf_prc_db ();ii_rc = -1

Choose Case is_caller
	Case "r0w_reg_rptcontrol%dupl_check"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = ls_rptcode   	//계정코드
//		lu_dbmgr.is_data[2] = ls_rptcont	//계정Cont코드

		//rpt_control
		Select count(rptcont)
		 Into :il_data[1]
		 From rpt_control
		Where rptcode = :is_data[1]
		  and rptcont <> :is_data[2];
		
		If SQLCA.SQLCode < 0 Then
			f_msg_sql_err(is_title, is_caller + " Select Error(rptcont)")
			Return 
		End If
		
		If il_data[1] > 0 Then
			f_msg_usr_err(9000, is_Title, " Duplicated data.")
			Return 
		End IF
		
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
	
End Choose

ii_rc = 0

Return 
end subroutine

public subroutine uf_prc_db_01 ();//"rpt0w_prt_daily_report%ue_ok"
String ls_yyyymmdd, ls_pageno, ls_wkcod, ls_desc_p, ls_desc_c
String ls_ltype, ls_reverseck,  ls_format, ls_bold, ls_italic, ls_underline
DEC{0} ldc_seq, ldc_linecnt, ldc_loadlevel, ldc_divlevel
Dec{2} ldc_cursum, ldc_monsum, ldc_yearsum, ldc_budgersum, ldc_last_sum
Dec{2} ldc_load_cursum, ldc_load_monsum, ldc_load_yearsum, ldc_load_budgetsum, ldc_load_lastsum
Dec{2} ldc_div_cursum, ldc_div_monsum, ldc_div_yearsum, ldc_div_budgetsum, ldc_div_lastsum
Dec{2} ldc_daysum_per, ldc_monsum_per, ldc_yearsum_per, ldc_budgetsum_per, ldc_lastsum_per
String ls_format_exp, ls_font_exp, ls_visible_exp, ls_visible_end
String ls_bold_exp, ls_italic_exp, ls_line_exp
Long ll_i

ii_rc = -1
Choose Case is_caller
	Case "rpt0w_prt_daily_report%ue_ok"
//		lu_dbmgr.is_title = Title
//		lu_dbmgr.is_data[1] = ls_yyyymmdd
//		lu_dbmgr.is_data[2] = ls_pageno
//		lu_dbmgr.is_data[3] = is_pagetype[1]
//		lu_dbmgr.idw_data[1] = dw_list
		
		ls_yyyymmdd = is_data[1]     //일자
		ls_pageno = is_data[2]       //pageno
		
		//1. 해당 TRDT구한다. 
		  DECLARE cur_rptdrive CURSOR FOR
			SELECT seq, linecnt, wkcod, desc_p, desc_c, 
				   ltype, loadlevel, divlevel, reverseck, format,
				   bold, underline, italic
			   FROM rptdrive
			 WHERE pageno = :ls_pageno
			ORDER BY pageno, seq;
		
		OPEN cur_rptdrive;
		
		If SQLCA.sqlcode < 0 Then
			f_msg_sql_err(is_caller, ":CURSOR cur_rptdrive")
			Return
		End If
		
		Do While(True)
			FETCH cur_rptdrive
			INTO :ldc_seq, :ldc_linecnt, :ls_wkcod, :ls_desc_p, :ls_desc_c,
			     :ls_ltype, :ldc_loadlevel, :ldc_divlevel, :ls_reverseck, :ls_format,
				 :ls_bold, :ls_underline, :ls_italic;
					
			If SQLCA.sqlcode < 0 Then
				f_msg_sql_err(is_caller, ":cur_rptdrive")
				CLOSE cur_rptdrive;
				Return 
			ElseIf SQLCA.SQLCode = 100 Then
				Exit
			End If	   
	   
		   IF ls_wkcod = 'L' Then
		
			  If not isnull(ldc_loadlevel) Then
			  
				   Select nvl(cursum,0), nvl(monsum,0), nvl(yearsum,0), nvl(budgetsum,0), nvl(last_sum,0)
					 Into :ldc_load_cursum, :ldc_load_monsum, :ldc_load_yearsum, :ldc_load_budgetsum, :ldc_load_lastsum
					 From rpt_level
				   Where yyyymmdd = :ls_yyyymmdd
					 And levelno = :ldc_loadlevel;
			 
				  If SQLCA.sqlcode < 0 Then
					  f_msg_sql_err(is_caller, "Select Error rpt_level [loadlevel]")
					  Return
				  ElseIf SQLCA.sqlcode  = 100 Then
					  ldc_load_cursum = 0  
					  ldc_load_monsum = 0
					  ldc_load_yearsum = 0
					  ldc_load_budgetsum = 0
					  ldc_load_lastsum = 0
				  End If
				  
			  End If				  

			  If not isnull(ldc_divlevel) Then
			  
				   Select nvl(cursum,0), nvl(monsum,0), nvl(yearsum,0), nvl(budgetsum,0), nvl(last_sum,0)
					 Into :ldc_div_cursum, :ldc_div_monsum, :ldc_div_yearsum, :ldc_div_budgetsum, :ldc_div_lastsum
					 From rpt_level
				   Where yyyymmdd = :ls_yyyymmdd
					 And levelno = :ldc_divlevel;
			 
				  If SQLCA.sqlcode < 0 Then
					  f_msg_sql_err(is_caller, "Select Error rpt_level [divlevel]")
					  Return
				  ElseIf SQLCA.sqlcode  = 100 Then
					  ldc_div_cursum = 0  
					  ldc_div_monsum = 0
					  ldc_div_yearsum = 0
					  ldc_div_budgetsum = 0
					  ldc_div_lastsum = 0
				  End If
				  
			   End If		
			   
			   //구성비(%)
			   IF ldc_div_cursum <> 0 and not isnull(ldc_div_cursum) then ldc_daysum_per = (ldc_load_cursum / ldc_div_cursum ) * 100
   			   IF ldc_div_monsum <> 0 and not isnull(ldc_div_monsum) then ldc_monsum_per = (ldc_load_monsum / ldc_div_monsum ) * 100
			   IF ldc_div_yearsum <> 0 and not isnull(ldc_div_yearsum) then ldc_yearsum_per = (ldc_load_yearsum / ldc_div_yearsum ) * 100
			   IF ldc_div_budgetsum <> 0 and not isnull(ldc_div_budgetsum) then ldc_budgetsum_per = (ldc_load_budgetsum / ldc_div_budgetsum ) * 100		   
			   IF ldc_div_lastsum <> 0 and not isnull(ldc_div_lastsum) then ldc_lastsum_per = (ldc_load_lastsum / ldc_div_lastsum ) * 100			   
			   
			   
			   If ls_reverseck = 'Y' Then
				    ldc_load_cursum = ldc_load_cursum * -1
					ldc_load_monsum = ldc_load_monsum * -1
					ldc_load_yearsum = ldc_load_yearsum * -1
					ldc_load_budgetsum  = ldc_load_budgetsum * -1
					ldc_load_lastsum = ldc_load_lastsum * -1
			   End IF
			   
	  		   //Insert Row
			   ll_i = idw_data[1].InsertRow(0)
			   idw_data[1].object.desc_p[ll_i] = ls_desc_p
			   idw_data[1].object.daysum[ll_i] = ldc_load_cursum
			   idw_data[1].object.daysum_per[ll_i] = ldc_daysum_per
			   idw_data[1].object.monsum[ll_i] = ldc_load_monsum
			   idw_data[1].object.monsum_per[ll_i] = ldc_monsum_per
			   idw_data[1].object.yearsum[ll_i] = ldc_load_yearsum
			   idw_data[1].object.yearsum_per[ll_i] = ldc_yearsum_per
			   idw_data[1].object.budgetsum[ll_i] = ldc_load_budgetsum
			   idw_data[1].object.budgetsum_per[ll_i] = ldc_budgetsum_per
			   idw_data[1].object.lastsum[ll_i] = ldc_load_lastsum
			   idw_data[1].object.lastsum_per[ll_i] = ldc_lastsum_per
			   
			   IF not Isnull(ls_format) Then
				   If ls_format_exp = "" Then ls_format_exp = "case( getrow() "
				   ls_format_exp +=  "When " + String(ll_i) + " then ~"" + ls_format+ "~" "
			   End If

		  ElseIf ls_wkcod = 'T' Then
			  
	  		   //Insert Row
			   ll_i = idw_data[1].InsertRow(0)
			   idw_data[1].object.desc_p[ll_i] = ls_desc_p
			   
//			   If ls_visible_exp = "" Then	ls_visible_exp  = "1~t"
			   ls_visible_exp += "If(getrow()=" + String(ll_i) + ",0,"
			   ls_visible_end += ")"
			   
		  End If
		  
	   	  IF ls_bold = "Y" Then       //Bold
			  
			   If ls_bold_exp = "" Then ls_bold_exp = "400~t case( getrow() "
			   ls_bold_exp +=  "When " + String(ll_i) + " then 700 "
		  End IF
		   
          If  ls_italic = "Y" Then  //Italic
			
			   If ls_italic_exp = "" Then ls_italic_exp = "0~t case( getrow() "
			   ls_italic_exp +=  "When " + String(ll_i) + " then 1 "
			   
		  End IF
		   
          If ls_underline = "Y" Then  //Underline
			
			   If ls_line_exp = "" Then ls_line_exp = "0~t case( getrow() "
			   ls_line_exp +=  "When " + String(ll_i) + " then 1 "
		   
     	  End iF
		  
		Loop
		CLOSE cur_rptdrive;
		
//	    If ls_visible_exp <> "" Then
//		    ls_visible_exp += "1" +ls_visible_end
//		    clipboard(ls_visible_exp)
//			messagebox("ls_visible_exp", ls_visible_exp)
////		    dw_1.Object.emp_stat.Visible="0~tIf(emp_class=1,0,1)"	
////			idw_data[1].daysum.Visible =  
//	//		dw_1.Modify("salary.format='~"###,###~"~t If(getrow()=1,~"#,##0~",If(getrow()=2,~"#,##0.00~",~"###~"))'") 
//			idw_data[1].Modify("daysum_per.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("daysum_per.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("monsum.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("monsum_per.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("yearsum.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("yearsum_per.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("budgetsum.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("budgetsum_per.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("lastsum.Visible= 1~t" + ls_visible_exp )	
//			idw_data[1].Modify("lastsum_per.Visible= 1~t" + ls_visible_exp )	
//    	End IF

		If ls_bold_exp <> "" Then
		    ls_bold_exp += " else 400)" 
			clipboard(ls_bold_exp)
		    idw_data[1].Modify("desc_p.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("daysum.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("daysum_per.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("monsum.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("monsum_per.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("yearsum.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("yearsum_per.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("budgetsum.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("budgetsum_per.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("lastsum.Font.Weight ='" + ls_bold_exp + "'")
			idw_data[1].Modify("lastsum_per.Font.Weight ='" + ls_bold_exp + "'")
		End If

		If ls_line_exp <> "" Then
		    ls_line_exp += " else 0)" 
			clipboard(ls_line_exp)
		    idw_data[1].Modify("desc_p.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("daysum.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("daysum_per.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("monsum.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("monsum_per.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("yearsum.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("yearsum_per.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("budgetsum.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("budgetsum_per.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("lastsum.Font.Underline ='" + ls_line_exp + "'")
			idw_data[1].Modify("lastsum_per.Font.Underline ='" + ls_line_exp + "'")
		End If
		
		If ls_italic_exp <> "" Then
		    ls_italic_exp += " else 0)" 
		    idw_data[1].Modify("desc_p.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("daysum.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("daysum_per.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("monsum.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("monsum_per.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("yearsum.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("yearsum_per.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("budgetsum.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("budgetsum_per.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("lastsum.Font.Italic ='" + ls_italic_exp + "'")
			idw_data[1].Modify("lastsum_per.Font.Italic ='" + ls_italic_exp + "'")
		End If

	    If ls_format_exp <> "" then
		    ls_format_exp += " else ~"###,###~")" 
	//		dw_1.Modify("salary.format='~"###,###~"~t If(getrow()=1,~"#,##0~",If(getrow()=2,~"#,##0.00~",~"###~"))'") 			
			idw_data[1].Modify("daysum.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("daysum_per.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("monsum.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("monsum_per.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("yearsum.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("yearsum_per.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("budgetsum.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("budgetsum_per.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("lastsum.format='~"###,###~"~t " + ls_format_exp + "'")
			idw_data[1].Modify("lastsum_per.format='~"###,###~"~t " + ls_format_exp + "'")
     	End IF

	
	Case Else
		f_msg_info_app(9000, "b1u_dbmgr.uf_prc_db()", &
							"Matching statement Not found(" + String(is_caller) + ")")
		Return  
	
End Choose

ii_rc = 0

Return 

end subroutine

on rpt0u_dbmgr.create
call super::create
end on

on rpt0u_dbmgr.destroy
call super::destroy
end on

