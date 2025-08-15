* Game with motion-captured animation for the TI-99/4A home computer.
*
* Copyright (c) 2024 Eric Lafortune
*
* This program is free software; you can redistribute it and/or modify it
* under the terms of the GNU General Public License as published by the Free
* Software Foundation; either version 2 of the License, or (at your option)
* any later version.
*
* This program is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
* FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
* more details.
*
* You should have received a copy of the GNU General Public License along
* with this program; if not, write to the Free Software Foundation, Inc.,
* 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

* Speech data: LPC coefficients for messages, exclamations, grunts,...

* Macro: Define a speech entry, consisting of the length word (expressed in
* bytes), followed by the LPC data.
* IN #1: the length of the speech data.
* IN #2: the file containing the speech data.
    .defm speech_entry
    data #1
    bcopy #2
    even
    .endm

* Speech data corresponding to in-game messages.
message_speech
    data collect_grenades
    data press_x_to_swap_weapons
    data collect_emp_batteries
    data distract_the_drone_with_stones
    data press_enter_to_throw_a_stone
    data collect_stones
    data walk_quietly_to_avoid_attention
    data run_to_escape_the_drone
    data press_shift_to_speed_up
    data press_7_to_restart_here
    data go_to_the_save_point
    data press_ctrl_to_heal
    data collect_medkits
    data move_with_the_keyboard_and_the_mouse

* Inconveniently, the file lengths have to be hardcoded here.

collect_grenades                     .speech_entry 265, '../out/CollectGrenades.lpc'
press_x_to_swap_weapons              .speech_entry 437, '../out/PressXToSwapWeapons.lpc'
collect_emp_batteries                .speech_entry 466, '../out/CollectEMPBatteries.lpc'
distract_the_drone_with_stones       .speech_entry 516, '../out/DistractTheDroneWithStones.lpc'
press_enter_to_throw_a_stone         .speech_entry 351, '../out/PressEnterToThrowAStone.lpc'
collect_stones                       .speech_entry 274, '../out/CollectStones.lpc'
walk_quietly_to_avoid_attention      .speech_entry 452, '../out/WalkQuietlyToAvoidAttention.lpc'
run_to_escape_the_drone              .speech_entry 309, '../out/RunToEscapeTheDrone.lpc'
press_shift_to_speed_up              .speech_entry 271, '../out/PressShiftToSpeedUp.lpc'
press_7_to_restart_here              .speech_entry 378, '../out/Press7ToRestartHere.lpc'
go_to_the_save_point                 .speech_entry 250, '../out/GoToTheSavePoint.lpc'
press_ctrl_to_heal                   .speech_entry 279, '../out/PressCtrlToHeal.lpc'
collect_medkits                      .speech_entry 280, '../out/CollectMedkits.lpc'
move_with_the_keyboard_and_the_mouse .speech_entry 464, '../out/MoveWithTheKeyboardAndTheMouse.lpc'

* Other speech.
speech_huh    .speech_entry   72, '../out/Huh.lpc'
speech_ah     .speech_entry   76, '../out/Ah.lpc'
speech_aah    .speech_entry  130, '../out/Aah.lpc'
speech_yeah   .speech_entry  107, '../out/Yeah.lpc'
