define( ["jquery"], function ( $ ) {
  'use strict';

  return {
    initialProperties: {
      version: 0.1,
      qHyperCubeDef: {
        qDimensions: [],
        qMeasures: [],
        qInitialDataFetch: [{
          qWidth: 10,
          qHeight:1000
        }]
      }
    },
    //property panel
    definition: {
      type: "items",
      component: "accordion",
      items: {
        dimensions: {
          uses: "dimensions",
          min: 1,
          max: 9
        },
        measures: {
          uses: "measures",
          min: 1,
          max: 9
        },
        sorting: {
          uses: "sorting"
        },
        settings: {
          uses: "settings"
        }
      }
    },
    snapshot: {
      canTakeSnapshot: true
    },

    paint: function ( $element, layout ) {

      var self = this, id = layout.qInfo.qId,
        html = "<div id='wrap" + id + "'>Hello, Shiny!",
        dimensions = layout.qHyperCube.qDimensionInfo,
        measures = layout.qHyperCube.qMeasureInfo,
        matrix = layout.qHyperCube.qDataPages[0].qMatrix;
      //elementの修正前に情報退避
      var oldurl = document.getElementById("url_input" + id);
      if(!oldurl){
        //create base html
        html += '<input id="url_input' + id + '" /><input type="button" value="start" onClick="$(\'#getShiny' + id + '\').css(\'display\', \'block\');testForm.action=document.getElementById(\'url_input' + id + '\').value;testForm.submit();" />';
        html += '<div id="testname' + id + '"></div>';
        html += '</div>';
        $element.html(html);
      }
      
      var divName = document.getElementById("testname" + id);
      var divHtml = '<div id="getShiny' + id + '" style="display: none;">';
      divHtml += '<form method="post" action="" target="mustUnique" name="testForm" id="testForm' + id + '"></form>';
      divHtml += '<iframe src="" name="mustUnique" style="position: relative;width:100%;height:800px;"></iframe></div>';
      divName.innerHTML = divHtml;
      divName.style = "background-color:white;";
      //initialize hidden datas...
      var strs = Array();
      var inputs = Array();
      var form = document.getElementById("testForm" + id);
      for(var i in matrix[0]){
        strs[i] = "";
        var input = document.createElement("input");
        input.type = "hidden";
        input.value = "";
        form.appendChild(input);
        inputs[i] = input;
      }
      var k = 0;
      for(var i in dimensions){
        inputs[k].name = dimensions[i]["qFallbackTitle"];
        k++;
      }
      for(var i in measures){
        inputs[k].name = measures[i]["qFallbackTitle"];
        k++;
      }
      try{
        //test
        var finalize = function(strs){
          for(var i in matrix[0]){
            inputs[i].value = strs[i].substring(1);
          }
          var oldurl = document.getElementById("url_input" + id).value;
          if(!(!oldurl)){
            //URL入力あり→更新したい。
            $('#getShiny' + id).css('display', 'block');
            testForm.action = document.getElementById('url_input' + id).value;
            testForm.submit();
          }
        };
        var getAllData = function(lastrow, strs){
          var c = self.backendApi.getRowCount();
          var requestPage = [{
                        qTop: lastrow + 1,
                        qLeft: 0,
                        qWidth: 10,
                        qHeight: Math.min(1000, c - lastrow )
                    }];
          self.backendApi.getData(requestPage).then(function (dataPages){
            for(var i in dataPages[0].qMatrix){
              for(var j in dataPages[0].qMatrix[0]){
                strs[j] += "," + dataPages[0].qMatrix[i][j].qText;
              }
            }
            if(c - lastrow > 1000){
              // continue
              getAllData(lastrow + 1000, strs);
            } else {
              // finalize
              finalize(strs);
            }
          });
        };
        getAllData(-1, strs);

      }catch(e){
        alert(e);
      }
      ////
    }
  };

} );
