//
//  WSYLineOptions.m
//  Travel_Card
//
//  Created by wangshiyong on 2017/10/13.
//  Copyright © 2017年 王世勇. All rights reserved.
//

#import "WSYLineOptions.h"

@implementation WSYLineOptions

+ (PYOption *)standardLineOption {
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textEqual(@"设备在线变化情况")
            .xEqual(@20)
            .subtextEqual(@"");
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
        }])
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@60).x2Equal(@45);
            grid.yEqual(@140);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.yEqual(@50);
            legend.textStyle.fontSize = @13;
            legend.dataEqual(@[@"总设备",@"在线设备",@"离线设备"]);
        }])
        .toolboxEqual([PYToolbox initPYToolboxWithBlock:^(PYToolbox *toolbox) {
            toolbox.showEqual(YES)
            .xEqual(PYPositionRight)
            .yEqual(PYPositionTop) //PYPositionTop
            .zEqual(@90)
            .featureEqual([PYToolboxFeature initPYToolboxFeatureWithBlock:^(PYToolboxFeature *feature) {
                feature.markEqual([PYToolboxFeatureMark initPYToolboxFeatureMarkWithBlock:^(PYToolboxFeatureMark *mark) {
                    mark.showEqual(NO);
                }])
                .dataViewEqual([PYToolboxFeatureDataView initPYToolboxFeatureDataViewWithBlock:^(PYToolboxFeatureDataView *dataView) {
                    dataView.showEqual(NO).readOnlyEqual(NO);
                }])
                .magicTypeEqual([PYToolboxFeatureMagicType initPYToolboxFeatureMagicTypeWithBlock:^(PYToolboxFeatureMagicType *magicType) {
                    magicType.showEqual(YES).typeEqual(@[PYSeriesTypeLine, PYSeriesTypeBar]);
                }])
                .restoreEqual([PYToolboxFeatureRestore initPYToolboxFeatureRestoreWithBlock:^(PYToolboxFeatureRestore *restore) {
                    restore.showEqual(YES);
                }]);
            }]);
        }])
//        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
//            dataZoom.showEqual(YES)
//            .realtimeEqual(YES)
//            .startEqual(@20)
//            .endEqual(@100);
//        }])
//        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
//            axis.typeEqual(PYAxisTypeCategory)
//            .boundaryGapEqual(@YES)
//            .axisTickEqual([PYAxisTick initPYAxisTickWithBlock:^(PYAxisTick *axisTick) {
//                axisTick.onGapEqual(NO);
//            }])
//            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *spliteLine) {
//                spliteLine.showEqual(NO);
//            }])
//            .addDataArr(@[@"9点",@"10点",@"11点",@"12点",@"13点",@"14点",@"15点",@"16点",@"17点",@"18点"]);
//        }])
//        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
//            axis.typeEqual(PYAxisTypeValue)
//            .scaleEqual(YES)
//            .boundaryGapEqual(@[@0.01, @0.01]);
//        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeCategory)
            .boundaryGapEqual(@NO)
            .addDataArr(@[@"9点",@"10点",@"11点",@"12点",@"13点",@"14点",@"15点",@"16点",@"17点",@"18点"]);
        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue)
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"{value}台");
            }]);
        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(@"总设备")
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(@[@(10000),@(10000),@(10000),@(10000),@(10000),@(10000),@(10000),@(10000),@(10000),@(10000)])
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": @"当前值"},@{@"type" : @"min", @"name": @"当前值"}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": @"平均值"}]);
            }]);

        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(@"在线设备")
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(@[@(8000),@(7000),@(7890),@(8123),@(1589),@(3244),@(5435),@(1589),@(3244),@(5435)])
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": @"最大值"},@{@"type" : @"min", @"name": @"最小值"}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": @"平均值"}]);
            }]);
        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(@"离线设备")
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(@[@(2000),@(3000),@(2890),@(1123),@(1589),@(5244),@(3435),@(8589),@(5244),@(8589)])
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": @"最大值"},@{@"type" : @"min", @"name": @"最小值"}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": @"平均值"}]);
            }]);
        }]);
    }];
}

+ (PYOption *)standardLineOptionWithSubtitle:(NSString *)subtitle
                               withTimeArray:(NSArray *)timeArray
                              withTotalArray:(NSArray *)totalArray
                             withOnlineArray:(NSArray *)onlineArray
                            withOfflineArray:(NSArray *)offlineArray
                                withEndEqual:(NSNumber *)value{
    return [PYOption initPYOptionWithBlock:^(PYOption *option) {
        option.titleEqual([PYTitle initPYTitleWithBlock:^(PYTitle *title) {
            title.textStyle.color = @("#181616");
            title.textEqual(WSY(@"Allocated equipment status"))
            .xEqual(@20)
            .subtextEqual(subtitle);
        }])
        .tooltipEqual([PYTooltip initPYTooltipWithBlock:^(PYTooltip *tooltip) {
            tooltip.triggerEqual(PYTooltipTriggerAxis);
        }])
        .gridEqual([PYGrid initPYGridWithBlock:^(PYGrid *grid) {
            grid.xEqual(@60).x2Equal(@45);
            grid.yEqual(@100);
        }])
        .legendEqual([PYLegend initPYLegendWithBlock:^(PYLegend *legend) {
            legend.yEqual(@60);
            legend.textStyle.fontSize = @13;
            legend.dataEqual(@[WSY(@"Total "),WSY(@"Online "),WSY(@"Offline ")]);
        }])
        .toolboxEqual([PYToolbox initPYToolboxWithBlock:^(PYToolbox *toolbox) {
            toolbox.showEqual(YES)
            .xEqual(@(kScreenWidth - 60))
            .yEqual(PYPositionTop) //PYPositionTop
            .zEqual(@90)
            .featureEqual([PYToolboxFeature initPYToolboxFeatureWithBlock:^(PYToolboxFeature *feature) {
                feature.markEqual([PYToolboxFeatureMark initPYToolboxFeatureMarkWithBlock:^(PYToolboxFeatureMark *mark) {
                    mark.showEqual(NO);
                }])
                .dataViewEqual([PYToolboxFeatureDataView initPYToolboxFeatureDataViewWithBlock:^(PYToolboxFeatureDataView *dataView) {
                    dataView.showEqual(NO).readOnlyEqual(NO);
                }])
                .magicTypeEqual([PYToolboxFeatureMagicType initPYToolboxFeatureMagicTypeWithBlock:^(PYToolboxFeatureMagicType *magicType) {
                    magicType.showEqual(NO).typeEqual(@[PYSeriesTypeLine, PYSeriesTypeBar]);
                }])
                .dataZoomEqual([PYToolboxFeatureDataZoom initPYToolboxFeatureDataZoomWithBlock:^(PYToolboxFeatureDataZoom *dataZoom){
                    dataZoom.showEqual(NO);
                }])
                .restoreEqual([PYToolboxFeatureRestore initPYToolboxFeatureRestoreWithBlock:^(PYToolboxFeatureRestore *restore) {
                    restore.showEqual(NO);
                }]);
            }]);
        }])
        .dataZoomEqual([PYDataZoom initPYDataZoomWithBlock:^(PYDataZoom *dataZoom) {
            dataZoom.showEqual(YES)
            .realtimeEqual(YES)
            .startEqual(@0)
            .endEqual(value);
            dataZoom.handleSize = @15;
            dataZoom.dataBackgroundColor = [PYColor colorWithHexString:@"#afafaf"];
//            dataZoom.handleColor = [PYColor colorWithHexString:@"#80e84127"];
        }])
        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeCategory)
            .boundaryGapEqual(@YES)
            .axisTickEqual([PYAxisTick initPYAxisTickWithBlock:^(PYAxisTick *axisTick) {
                axisTick.onGapEqual(NO);
            }])
            .splitLineEqual([PYAxisSplitLine initPYAxisSplitLineWithBlock:^(PYAxisSplitLine *spliteLine) {
                spliteLine.showEqual(NO);
            }])
            .addDataArr(timeArray);
        }])
//        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
//            axis.typeEqual(PYAxisTypeValue)
//            .scaleEqual(YES)
//            .boundaryGapEqual(@[@0.01, @0.01])
//            ;
//        }])
//        .addXAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
//            axis.typeEqual(PYAxisTypeCategory)
//            .boundaryGapEqual(@NO)
//            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
//                axisLabel.formatterEqual(@"{value}点");
//            }])
//            .addDataArr(timeArray);
//        }])
        .addYAxis([PYAxis initPYAxisWithBlock:^(PYAxis *axis) {
            axis.typeEqual(PYAxisTypeValue)
            .boundaryGapEqual(@[@0.01, @0.01])
            .axisLabelEqual([PYAxisLabel initPYAxisLabelWithBlock:^(PYAxisLabel *axisLabel) {
                axisLabel.formatterEqual(@"{value}");
            }]);
        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(WSY(@"Total "))
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(totalArray)
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": WSY(@"Current Value")},@{@"type" : @"min", @"name": WSY(@"Current Value")}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": WSY(@"Average")}]);
            }]);
        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(WSY(@"Online "))
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(onlineArray)
            .itemStyleEqual([PYItemStyle initPYItemStyleWithBlock:^(PYItemStyle *itemStyle) {
                itemStyle.normalEqual([PYItemStyleProp initPYItemStylePropWithBlock:^(PYItemStyleProp *normal) {
                    normal
//                     .colorEqual([PYColor colorWithHexString:@"#afafaf"])
//                     .barBorderColorEqual(@"tomato")
                    .barBorderWidthEqual(@6)
                    .barBorderRadiusEqual(@0)
                    .labelEqual([PYLabel initPYLabelWithBlock:^(PYLabel *label) {
                        label.showEqual(YES)
                        .positionEqual(@"top")
                        .textStyleEqual([PYTextStyle initPYTextStyleWithBlock:^(PYTextStyle *textStyle) {
                             textStyle.colorEqual(@"tomato");
                        }]);
                    }]);
                }]);
            }])
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": WSY(@"Maximum")},@{@"type" : @"min", @"name": WSY(@"Minimum")}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": WSY(@"Average")}]);
            }]);
        }])
        .addSeries([PYSeries initPYSeriesWithBlock:^(PYSeries *series) {
            series.nameEqual(WSY(@"Offline "))
            .typeEqual(PYSeriesTypeLine)
            .dataEqual(offlineArray)
            .markPointEqual([PYMarkPoint initPYMarkPointWithBlock:^(PYMarkPoint *point) {
                point.addDataArr(@[@{@"type" : @"max", @"name": WSY(@"Maximum")},@{@"type" : @"min", @"name": WSY(@"Minimum")}]);
            }])
            .markLineEqual([PYMarkLine initPYMarkLineWithBlock:^(PYMarkLine *markLine) {
                markLine.addDataArr(@[@{@"type" : @"average", @"name": WSY(@"Average")}]);
            }]);
        }]);
    }];
}

@end
