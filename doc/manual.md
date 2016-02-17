MulVal
======

Mulval uses 2 kinds of file:
* rule file (_e.g._ example\_rule.P)
* input file (_e.g._ example\_input.P)
They use the Datalog (a subset of Prolog) syntax.

## Rule file ##

In this file are defined *interaction rules*, represented by oval nodes ("AND" nodes) in the attack graph. Those rules are based on *predicates*, which have to be declared somewhere in the file.

### Predicates ###

There are two types of predicates:
* **primitive**: they represent preconditions and are represented by rectangle nodes in the attack graph.
* **derived**: they are defined by the interaction rules and correspond to postconditions. They are represented by diamond-shaped nodes ("OR" nodes) in the attack graph. To improve the efficiency of the XSB reasoning, all derived predicates should be tabled; this allows the XSB engine to memorize intermediate results.

### Syntax ###

Note: Everything ends with a period '.'.

Declare a primitive:

	primitive(primitive_name(_parameter, ...)).

Note that parameters must start with an underscore '\_'.

Declare a derived:

	derived(derived_name(_parameter, ...)).

Table a derived:

	:- table derived_name/number_of_parameters.

Declare an interaction rule:

	interaction_rule(
		(derived_name(Parameter, ...) :- predicate(Parameter, ...), ...),
		rule_desc('rule description', number)).


Remarks:
* _predicate_ could be either a primitive or a derived.
* The _number_ parameter in rule\_desc is still mysterious.
* The rule description string **MUST** be between quotes and contain at least 2 words.
* Variables must start with an uppercase letter, and constants must start with a lowercase letter.
* If we do not need to name a variable (namely, if it is only used at one place in the rule), we can simply put an underscore '\_'.

## Input file ##

MulVal generates the attack graph from these files using the rules defined in one or more rule files. It basically is a description of the system for which the attack graph will be generated: location of attacers, vulnerabilities, machines, programs runnings, ACL, etc.

## EXAMPLES ##

Below are minimal examples for a rule file and an input file. The resulting graph describes a code execution with root permission on a machine if this machine is accessible from the internet and if a certain vulnerable program is running on it.

### example\_rules.P ###

	/*Predicates declarations*/
	primitive(attackerLocated(_location)).
	primitive(hacl(_src, _dst, _prot, _port)).
	primitive(vulExists(_host, _vulID, _program)).
	primitive(vulProperty(_vulID, _range, _consequence)).
	primitive(progRunning(_program, _host)).

	derived(execCode(_host, _permission)).
	derived(netAccess(_host, _protocol, _port)).

	meta(attackGoal(_)).

	/* Tabling predicates */
	:- table execCode/2.
	:- table netAccess/3.

	/* interaction rules */
	interaction_rule(
		(execCode(Host, root) :- vulExists(Host, _, Program), progRunning(Program, Host), netAccess(Host, _, _)),
		rule_desc('Vulnerable program is running on remotely accessible host', 2)).

	interaction_rule(
		(netAccess(H, Protocol, Port) :-
			attackerLocated(Zone),
			hacl(Zone, H, Protocol, Port)),
		rule_desc('direct network access', 1)).

### example\_input.P ###

	attackerLocated(internet).
	attackGoal(execCode(unicorn, root)).

	hacl(internet, unicorn, tcp, 80).

	vulExists(unicorn, 'All your base are belong to us', 'Zero Wing').
	vulProperty('All your base are belong to us', remoteExploit, execCode).
	progRunning('Zero Wing', unicorn).

## Generate the attack graph ##

To generate the graph once the rule file and the input file are written, use `$MULVALROOT/utils/graph_gen.sh INPUT_FILE` .

### Options ###

Below are some basic options:

* -r | --rulefile RULE\_FILE: use RULE\_FILE to generate the graph. By default MulVal uses $MULVALROOT/running\_rules.P.
* -v: output the graph in .csv and .pdf format
* -p: perform deep trimming on the attack graph to improve visualization (SHOULD NOT BE INVOKED IN PRODUCTION USE)
* --nometric: do not show the metric information

### Notes ###

1. Avoid using non-alphanumeric characters when passing parameters. Characters to avoid include: colons ":". But it is probably not an exhaustive list)
2. Rule descriptions **MUST NOT** be void, or MulVal will just take one randomly (?)
