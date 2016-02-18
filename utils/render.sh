#!/bin/sh
# Rendering attack graph based on CSV output
# Author: Xinming Ou
# Copyright (C) 2011, Argus Cybersecurity Lab, Kansas State University

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.
output_file="AttackGraph"
ac_prev=
for ac_option
do
  # If the previous option needs an argument, assign it.
  if test -n "$ac_prev"; then
    eval "$ac_prev=\$ac_option"
    ac_prev=
    continue
  fi

  case "$ac_option" in
      --arclabel)
      arclabel=true ;;

      --reverse)
      reverse=true ;;

      --nometric)
      nometric=true ;;

      --simple)
      simple=true ;;

	  -o)
	  ac_prev=output_file;;

      *)
#      -h | --help)
      cat <<EOF
Usage: render.sh [options]
Options:
    --arclabel: Output labels  for the arcs
    --reverse: Output the arcs in the reverse order
    --simple: Do not show the vertex fact labels
	--nometric: Do not show the metric information
    -o output_name: Specify name of the output
    -h|--help: Display this help
EOF
      exit ;;
  esac
done


echo "Producing attack graph through GraphViz"

echo digraph G { > $output_file.dot

if test -n "$simple"; then
    if test -n "$nometric"; then
	vertice_sed_file=$MULVALROOT/utils/VERTICES_simple_no_metric.sed
    else
	vertice_sed_file=$MULVALROOT/utils/VERTICES_simple.sed
    fi
else
    if test -n "$nometric"; then
	vertice_sed_file=$MULVALROOT/utils/VERTICES_no_metric.sed
    else
	vertice_sed_file=$MULVALROOT/utils/VERTICES.sed
    fi
fi
sed -f $vertice_sed_file VERTICES.CSV >> $output_file.dot

if test -n "$reverse"; then
    if test -n "$arclabel"; then
	sed -f $MULVALROOT/utils/ARCS_reverse.sed ARCS.CSV >> $output_file.dot
    else
	sed -f $MULVALROOT/utils/ARCS_reverse_noLabel.sed ARCS.CSV >> $output_file.dot
    fi
else
    if test -n "$arclabel"; then
	sed -f $MULVALROOT/utils/ARCS.sed ARCS.CSV >> $output_file.dot
    else
	sed -f $MULVALROOT/utils/ARCS_noLabel.sed ARCS.CSV >> $output_file.dot
    fi
fi

echo } >> $output_file.dot

dot -Tps $output_file.dot > $output_file.eps
epstopdf $output_file.eps

echo "If successfully produced, the attack graph should be in $output_file.pdf"

if test -n "$PDF_READER"; then
    $PDF_READER $output_file.pdf&
fi
