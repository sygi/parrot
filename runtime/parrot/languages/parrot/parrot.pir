# Copyright (C) 2009, Parrot Foundation.
# $Id$

.HLL 'parrot'
.namespace ['Parrot';'Compiler']

.sub 'load' :anon :load :init
    # I'm not sure if this is completely right...
    .local pmc p6meta, c
    load_bytecode 'PCT.pbc'
    p6meta = get_hll_global 'P6metaclass'
    c = p6meta.'new_class'('Parrot::Compiler', 'parent'=>'PCT::HLLCompiler')
    c.'language'('parrot')
.end

.sub 'load_library' :method
    .param pmc name
    .param pmc extra :named :slurpy
    .local pmc name, library, inc_hash
    .local string file
    $I0 = does name, 'array'
    if $I0 goto have_namelist
    $S0 = name
    name = split '::', $S0
  have_namelist:
    file = join '/', name
    file = concat file, '.pir'
    load_bytecode file
    library = new 'Hash'
    library['name'] = name
    library['filename'] = file
    # If this fails, we should build a hash of DEFAULT and ALL => the normal ns
    $P0 = get_hll_global name, 'EXPORT'
    library['symbols'] = $P0
    $P0 = get_hll_namespace name
    library['namespace'] = $P0
    .return (library)
  fail:
    # TODO: better fail?
    .return (0)
.end

.sub 'export' :method
    .param string list
    # This should accept a tag...
    .local pmc syms, i, ns, relns, exportns
    # We should default to all symbols when none are specified
    syms = split ' ', list
    i = getinterp
    ns = i['namespace';1]
    relns = new 'ResizablePMCArray'
    relns.'push'('EXPORT')
    # This could be a loop, I guess...
    relns.'push'('ALL')
    exportns = ns.'make_namespace'(relns)
    ns.'export_to'(exportns, syms)
    relns.'pop'()
    relns.'push'('DEFAULT')
    exportns = ns.'make_namespace'(relns)
    ns.'export_to'(exportns, syms)
.end

# TODO Should this provide support for loading HLL libraries?

=head1 NAME

languages/parrot/parrot.pir - Compiler object for interop between HLLs and
Parrot-hosted languages

=head1 SYNOPSIS

    # NameSpace MUST match path!
    .namespace ['Foo']
    .sub 'load' :anon :load :init
        .local pmc c
        load_language 'parrot'
        c = compreg 'parrot'
        c.'export'('dance leap')
    .end

    .sub 'dance'
        say 'lol dancing'
    .end

    .sub 'leap'
        say 'like dancing, but fancier'
    .end

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
