{extends file="file:[Core]viewLayout.tpl"}

{block name="title"}{t}Graphs{/t}{/block}

{block name="style-head"}
<style>
.delete-graph {
  cursor: pointer;
}
</style>
{/block}

{block name="content"}
<div class="content-container">
  <div class="panel panel-default">
    <div class="panel-heading">
      <div class="row search">
        <form role="form">
          <div class="form-group col-md-3">
            <input type="text" name="period" class="form-control" placeholder="Period" >
          </div>
          <div class="form-group col-md-5">
            <div class="input-group">
              <input type="text" id="service" name="service" class="form-control" >
              <span class="input-group-btn">
                <button class="btn btn-default" type="button" id="addGraph">{t}Add{/t}</button>
              </span>
            </div>
          </div>
          <div class="form-group col-md-4">
            <div class="input-group">
              <span class="input-group-btn">
                <button class="btn btn-default" data-toggle="tooltip" data-placement="bottom" title="{t}Load{/t}" id="loadView"><i class="fa fa-upload"></i></button>
                <button class="btn btn-default" data-toggle="tooltip" data-placement="bottom" title="{t}Save{/t}" id="saveView"><i class="fa fa-floppy-o"></i></button>
                <button class="btn btn-default" data-toggle="tooltip" data-placement="bottom" title="{t}Delete{/t}" id="deleteView"><i class="fa fa-trash-o"></i></button>
              </span>
              <input type="text" id="view" name="view" class="form-control">
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
  <div id="graphs"></div>
</div>
<div class="modal fade" id="saveViewModal" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
        <h4 class="modal-title">{t}Save view{/t}</h4>
      </div>
      <div class="modal-body">
        <form role="role" class="form-horizontal">
          <div class="form-group">
            <div class="col-sm-2" style="text-align: right">
              <label class="label-controller" for="name">{t}Name{/t}</label>
              <span style="color: red">*</span>
            </div>
            <div class="col-sm-9">
              <input type="text" name="name" class="form-control mandatory-field" placeholder="{t}Name{/t}">
            </div>
          </div>
          <div class="form-group">
            <div class="col-sm-2" style="text-align: right">
              <label class="label-controller" for="name">{t}Pricacy{/t}</label>
              <span style="color: red">*</span>
            </div>
            <div class="col-sm-9">
              <label class="label-controller" for="mode1">
                &nbsp;<input type="radio" name="privacy" value="1"> Public
              </label>
              <label class="label-controller" for="mode2">
                &nbsp;<input type="radio" name="privacy" value="0" checked> Private
              </label>
            </div>
          </div>
        </form>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-default" data-dismiss="modal">{t}Close{/t}</button>
        <button type="button" class="btn btn-primary" id="saveViewButton">{t}Save{/t}</button>
      </div>
    </div>
  </div>
</div>
{/block}

{block name="javascript-bottom" append}
<script>
var nbGraph = 0;

function createGraph(serviceId) {
  var graphId, startTime, endTime,
      time = $("input[name='period']").val();

  ++nbGraph;
  graphId = "graph-" + nbGraph;
  
  /* Add graph */
  $("<div></div>")
    .addClass("graph")
    .data("serviceId", serviceId)
    .append(
      $("<div></div>")
        .css("height", 22)
        .append(
          $("<button></button>")
            .addClass("delete-graph")
            .addClass("close")
            .attr("type", "button")
            .html("&times;")
        )
    )
    .append(
      $("<div></div>")
        .addClass("c3")
        .attr("id", graphId)
    )
    .appendTo($("#graphs"));
  
  startTime = moment(time.split(" - ")[0]).format('X');
  endTime = moment(time.split(" - ")[1]).format('X');
  addChart(graphId, serviceId, startTime, endTime);
}

function saveView(viewId, graphs, viewName, viewPrivacy) {
  $.ajax({
    url: "{url_for url="/graph/view"}",
    method: "POST",
    data: {
      viewId: viewId,
      viewName: viewName,
      viewPrivacy: viewPrivacy,
      graphs: graphs
    },
    dataType: "json",
    success: function(data, textStatus, jqXHR) {
      if (data.success) {
        alertMessage("{t}Graph view saved{/t}", "alert-success", 3);
      } else {
        alertMessage("{t}Error when trying to save graph view{/t}", "alert-critical");
      }
    }
  });
}

$(function() {
  /* Iniialiaze period */
  var endTime = moment(),
      startTime = moment(endTime).subtract(24, 'hours');

  /* Load tooltip */
  $("[data-toggle='tooltip']").tooltip();

  /* Action on save */
  $("#saveViewButton").on("click", function(e) {
    var graphs = [];
    $(".graph").each(function(idx, element) {
      graphs.push({
        "type": "service",
        "id": $(element).data("serviceId")
      });
    });
    saveView("", graphs, $("input[name='name']").val(), $("input[name='privacy']:checked").val());
    $("#saveViewModal").modal("hide");
  });

  /* Action delete a view */
  $("#deleteView").on("click", function(e) {
    var viewId = $("#view").val();
    e.preventDefault();
    if (viewId === "") {
      return;
    }
    
    $.ajax({
      url: "{url_for url="/graph/view"}/" + viewId,
      dataType: "json",
      method: "DELETE",
      success: function(data, textStatus, jqXHR) {
        if (data.success) {
          alertMessage("{t}The graph view is deleted{/t}", "alert-success", 3);
          // @todo reset select2 field
        } else {
          alertMessage("{t}Error during delete graph view{/t}", "alert-critical");
        }
      }
    });
  });

  /* Action on delete */
  $("#graphs").on("click", ".delete-graph", function(e) {
    var $element = $(e.currentTarget);
    id = $element.parents(".graph").find(".c3").attr("id").replace("graph-", "");
    charts[id - 1] = null;
    $element.parents(".graph").remove();
  });

  /* Initialize service selection */
  $("#service").select2({
    placeholder: "Select a service",
    allowClear: true,
    ajax: {
      data: function(term, page) { return { q: term }; },
      dataType: "json",
      url: "{url_for url="/configuration/service/formlist"}" ,
      results: function(data) { return { results: data, more: false }; }
    }
  });

  /* Initialize list view */
  $("#view").select2({
    placeholder: "Load a view",
    allowClear: true,
    ajax: {
      data: function(term, page) { return { q: term }; },
      dataType: "json",
      url: "{url_for url="/graph/view"}" ,
      results: function(data) { return { results: data, more: false }; }
    }
  });

  /* Initialize dateragepicker */
  $("input[name='period']").daterangepicker({
    timePicker: true,
    timePickerIncrement: 5,
    timePicker12Hour: false,
    format: 'YYYY-MM-DD HH:mm',
    startDate: startTime,
    endDate: endTime,
    ranges: {
      "8 hours": [moment().subtract(8, 'hours'), moment()],
      "24 hours": [moment().subtract(24, 'hours'), moment()],
      "1 week": [moment().subtract(7, 'days'), moment()],
      "1 month": [moment().subtract(1, 'months'), moment()]
    }
  });
  $("input[name='period']").val(startTime.format('YYYY-MM-DD HH:mm') + " - " + endTime.format('YYYY-MM-DD HH:mm'));

  $("#addGraph").on("click", function() {
      var inView = false,
        serviceId = $("#service").val();
    /* Search if the service is already in view */
    $(".graph").each(function(idx, element) {
      if ($(element).data("serviceId") === serviceId) {
        inView = true;
      }
    });
    if (inView) {
      return;
    }
    
    createGraph(serviceId);
  });

  $("input[name='period']").on("apply.daterangepicker", function() {
    var startTime, endTime,
        time = $("input[name='period']").val();
    if ($("#service").val() === undefined) {
      return;
    }
    startTime = moment(time.split(" - ")[0]).format('X');
    endTime = moment(time.split(" - ")[1]).format('X');
    updateChart(startTime, endTime);
  });

  $("#saveView").on("click", function(e) {
    var graphs = [],
        viewName = "",
        viewId = $("#view").val();
    e.preventDefault();
    /* Get all graph in page*/
    $(".graph").each(function(idx, element) {
      graphs.push({
        "type": "service",
        "id": $(element).data("serviceId")
      });
    });
    /* Stop if there are no graph in view */
    if (graphs.length === 0) {
      alertMessage("No graph selected", "alert-warning");
      setTimeout(alertClose, 5000);
      return;
    }

    if (viewId === "") {
      $("input[name='name']").val("");
      $("input[name='privacy'][value='0']").attr("checked", "checked"); // TODO better
      $("#saveViewModal").modal("show"); 
    } else {
      saveView(viewId, graphs, "", 0);
    }
  });

  $("#loadView").on("click", function(e) {
    var viewId = $("#view").val();
    e.preventDefault();
    if (viewId === "") {
      return;
    }
    $.ajax({
      url: "{url_for url="/graph/view"}/" + viewId,
      dataType: "json",
      method: "GET",
      success: function(data, textStatus, jqXHR) {
        charts = [];
        nbGraph = 0;
        $(".graph").each(function(idx, element) {
          $(element).remove();
        });
        $.each(data.graphs, function(idx, graph) {
          createGraph(graph['id']);
        });
      }
    });
  });
});
</script>
{/block}
