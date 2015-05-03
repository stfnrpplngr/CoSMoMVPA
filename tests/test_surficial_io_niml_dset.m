function test_suite = test_surficial_io_niml_dset
    initTestSuite;


function test_niml_dset_dataset_io()
    if cosmo_skip_test_if_no_external('afni')
        return;
    end

    ds=cosmo_synthetic_dataset('ntargets',2,'nchunks',1,...
                        'type','surface');
    ds.a.fdim.values{1}=1+[1 4 7 8 5 3];
    ds.sa.stats={'Ftest(3,4)';'Zscore()'};
    ds.sa.labels={'label1';'label2'};

    fn=cosmo_make_temp_filename('_tmp','.niml.dset');
    cleaner=onCleanup(@()delete(fn));

    niml_str=get_niml_dset_string('ascii');
    fid=fopen(fn,'w');
    fprintf(fid,'%s',niml_str);
    fclose(fid);

    ds2=cosmo_surface_dataset(fn);
    assert_dataset_equal(ds,ds2);

function assert_dataset_equal(x,y)
    assertElementsAlmostEqual(x.samples,y.samples,'absolute',1e-5);
    assertEqual(sort(fieldnames(x)),sort(fieldnames(y)));
    assertEqual(x.fa,y.fa);
    assertEqual(x.a,y.a);


function string=get_niml_dset_string(format)
    string=[...
            get_niml_dset_header() ...
            get_niml_dset_data(format) ...
            get_niml_dset_footer()
            ];



function string=get_niml_dset_header()
    string=sprintf([...
            '<AFNI_dataset\n' ...
            '  dset_type="Node_Bucket"\n' ...
            '  self_idcode="XYZ_QJCWHYMMSUIUXCMBUZJASSJT"\n' ...
            '  filename="data.niml.dset"\n' ...
            '  label="data.niml.dset"\n' ...
            '  ni_form="ni_group" >\n' ...
            ]);

function string=get_niml_dset_footer()
    string=sprintf([...
            '<AFNI_atr\n' ...
            '  atr_name="COLMS_RANGE"\n' ...
            '  ni_type="String"\n' ...
            '  ni_dimen="1" >\n' ...
            '"-3.6849477 2.0316862 1 0;-1.3264908 2.3386572 2 4"'...
                        '</AFNI_atr>\n' ...
            '<AFNI_atr\n' ...
            '  atr_name="COLMS_LABS"\n' ...
            '  ni_type="String"\n' ...
            '  ni_dimen="1" >\n' ...
            '"label1;label2"</AFNI_atr>\n' ...
            '<AFNI_atr\n' ...
            '  atr_name="COLMS_TYPE"\n' ...
            '  ni_type="String"\n' ...
            '  ni_dimen="1" >\n' ...
            '"Generic_Float;Generic_Float"</AFNI_atr>\n' ...
            '<AFNI_atr\n' ...
            '  atr_name="COLMS_STATSYM"\n' ...
            '  ni_type="String"\n' ...
            '  ni_dimen="1" >\n' ...
            '"Ftest(3,4);Zscore()"</AFNI_atr>\n' ...
            '</AFNI_dataset>\n' ...
            ]);

function string=get_niml_dset_data(format)
    switch lower(format)
        case 'ascii'
            bucket_data=sprintf([...
                            '\n'...
                            '2.0316862 0.5838057\n' ...
                            '-3.6849477 1.7235005\n' ...
                            '-1.0504489 -1.3264908\n' ...
                            '1.3494419 -0.3973336\n' ...
                            '-0.2617231 2.3386572\n' ...
                            '-0.2039545 0.4823448\n' ...
                            '\n'...
                            ]);
            node_data=sprintf([...
                            '\n'...
                            '1\n' ...
                            '4\n' ...
                            '7\n' ...
                            '8\n' ...
                            '5\n' ...
                            '3\n' ...
                            '\n'...
                            ]);
            ni_form='';

        case 'binary'
            bucket_data=[    38      7      2     64     74    116 ...
                             21     63     47  65533    107  65533 ...
                          65533  65533  65533     63     28    117 ...
                          65533  65533    115  65533  65533  65533 ...
                          65533  65533  65533     63     79    111 ...
                          65533  65533  65533      0  65533  65533 ...
                          65533  65533     21     64    115  65533 ...
                             80  65533  65533  65533  65533     62];
            node_data=  [     1      0      0      0      4      0 ...
                              0      0      7      0      0      0 ...
                              8      0      0      0      5      0 ...
                              0      0      3      0      0      0];
            ni_form=sprintf('  ni_form="binary.lsbfirst"\n');


        otherwise
            error('unsupported format %s', format);
    end

    string=[...
            sprintf([...
                '<SPARSE_DATA\n' ...
                '  data_type="Node_Bucket_data"\n' ...
                '  ni_type="2*float"\n' ...
                ni_form ...
                '  ni_dimen="6" >' ])...
            bucket_data ...
            sprintf([...
                '</SPARSE_DATA>\n' ...
                '<INDEX_LIST\n' ...
                '  data_type="Node_Bucket_node_indices"\n' ...
                '  sorted_node_def="No"\n' ...
                '  COLMS_RANGE="1 8 0 3"\n' ...
                '  COLMS_LABS="Node Indices"\n' ...
                '  COLMS_TYPE="Node_Index"\n' ...
                '  ni_type="int"\n' ...
                ni_form ...
                '  ni_dimen="6" >']) ...
                node_data ...
                sprintf([...
                '</INDEX_LIST>\n' ])...
            ];

