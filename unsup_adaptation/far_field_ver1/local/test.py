import os
import sys

import kaldi_io
import numpy as np
import argparse
from workspace.pytorch_utils.enhancement_bwe.data_loaders import PytorchSeqDataLoaderVer1
from torch.utils import data

'''

src_dir = '/export/b16/snidada1/test_remove_later'

exp_dir = 'exp/test_dir'


if not os.path.isdir(src_dir):
    os.makedirs(src_dir)
if not os.path.isdir(exp_dir):
    os.makedirs(exp_dir)

if not os.path.isdir(os.path.join(exp_dir, 'storage')):
    os.symlink(src_dir, os.path.join(exp_dir, 'storage'))

if not os.path.isfile('temp.ark'):
    os.symlink(os.path.join(exp_dir, 'storage', 'temp.ark'), 'temp.ark')

fout = kaldi_io.open_or_fd('temp.ark', 'wb')

for i in range(10):
    fea = np.random.randn(13,2)
    key = 'fea' + str(i)
    kaldi_io.write_mat(fout, fea, key)

fout.close()
'''


params = {'batch_size':1, 'shuffle':False}

ins = PytorchSeqDataLoaderVer1('data/fbank_wb_mel_40/voices19_challenge_dev_enroll_no_sil/feats.scp')

print(len(ins))
dl = data.DataLoader(ins, **params)

for i in range(5):
    k,m = ins[i]
    print(np.shape(m), k)

def foo():
    for i in range(5):
        yield i

f=foo()
print(next(f))
print(next(f))
print(next(f))
print(next(f))
print(next(f))
print(next(f))
