*&---------------------------------------------------------------------*
*& Report ZC8A_005_DEMO_REP
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zc8a_005_demo_rep.


INCLUDE zc8a_005_demo_rep_data if FOUND. " types/data
INCLUDE zc8a_005_demo_rep_cls10 if FOUND. " base demo
INCLUDE zc8a_005_demo_rep_cls11 if FOUND. " add01 demo

INCLUDE zc8a_005_demo_rep_scrn if FOUND. " selection screen
INCLUDE zc8a_005_demo_rep_cls99 if FOUND. " all application
INCLUDE zc8a_005_demo_rep_evnt if FOUND. " Executable report - events
