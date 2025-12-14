import torch
import torch.nn as nn
import math
from models.quant_layer import *



cfg = {
    'VGG11': [64, 'M', 128, 'M', 256, 256, 'M', 512, 512, 'M', 512, 512, 'M'],
    'VGG13': [64, 64, 'M', 128, 128, 'M', 256, 256, 'M', 512, 512, 'M', 512, 512, 'M'],
    'VGG16_quant': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512, 'M', 512, 512, 512, 'M'],
    'VGG16_quant_project_part1': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 8, 8, 512, 'M', 512, 512, 512, 'M'],
    'VGG16_quant_project_part2': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 16, 16, 512, 'M', 512, 512, 512, 'M'],
    'VGG16': ['F', 64, 'M', 128, 128, 'M', 256, 256, 256, 'M', 512, 512, 512, 'M', 512, 512, 512, 'M'],
    'VGG19': [64, 64, 'M', 128, 128, 'M', 256, 256, 256, 256, 'M', 512, 512, 512, 512, 'M', 512, 512, 512, 512, 'M'],
}


class VGG_quant(nn.Module):
    def __init__(self, vgg_name, a_bit=4, w_bit=4):
        super(VGG_quant, self).__init__()
        self.a_bit = a_bit
        self.w_bit = w_bit
        self.features = self._make_layers(cfg[vgg_name])
        self.classifier = nn.Linear(512, 10)

    def forward(self, x):
        out = self.features(x)
        out = out.view(out.size(0), -1)
        out = self.classifier(out)
        return out

    def _make_layers(self, cfg):
        layers = []
        in_channels = 3
        for x in cfg:
            if x == 'M':
                layers += [nn.MaxPool2d(kernel_size=2, stride=2)]
            elif x == 'F':  # This is for the 1st layer (unchanged)
                layers += [nn.Conv2d(in_channels, 64, kernel_size=3, padding=1, bias=False),
                           nn.BatchNorm2d(64),
                           nn.ReLU(inplace=True)]
                in_channels = 64
            else:
                if in_channels == 8 or in_channels ==16:  # This is for the projected layers
                    layers += [QuantConv2d(in_channels, x, kernel_size=3, padding=1, w_bit=self.w_bit, a_bit=self.a_bit),
                               nn.ReLU(inplace=True)]
                else:
                    layers += [QuantConv2d(in_channels, x, kernel_size=3, padding=1, w_bit=self.w_bit, a_bit=self.a_bit),
                               nn.BatchNorm2d(x),
                               nn.ReLU(inplace=True)]
                in_channels = x
        layers += [nn.AvgPool2d(kernel_size=1, stride=1)]
        return nn.Sequential(*layers)

    def show_params(self):
        for m in self.modules():
            if isinstance(m, QuantConv2d):
                m.show_params()
    

def VGG16_quant(**kwargs):
    model = VGG_quant(vgg_name = 'VGG16_quant', **kwargs)
    return model

def VGG16_quant_project_part1(**kwargs):
    model = VGG_quant(vgg_name = 'VGG16_quant_project_part1',a_bit=4,w_bit=4, **kwargs)
    return model

def VGG16_quant_project_part2(**kwargs):
    model = VGG_quant(vgg_name = 'VGG16_quant_project_part2',a_bit=2, w_bit=4, **kwargs)
    return model