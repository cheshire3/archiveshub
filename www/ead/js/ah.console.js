
var Console = {

    init: function() {
        Console.upload();
    },

    upload: function() {

        $('#files').change(updatePrettyFileList);

        $('#uploadButton').click(function(evt) {
            $('#files').hide();
            $('#uploadButton').hide();
            $('#abortButton').show();
            $('#uploadStatus').html('Uploading&hellip;');
            $('#cancelButton').hide();
            var files = document.forms['upload-form']['files'].files;
            failures = new Array();
            for (var i = 0, f; f = files[i]; i++) {
                sendFile(f);
            }
        });

        $('#abortButton').click(function(evt) {
            clearFiles();
            $('#abortButton').hide();
            $('#cancelButton').show();
            for (var i = 0, r; r = requests[i]; i++) {
                r.abort();
            }
        });

        $('#cancelButton').click(function(evt) {
            clearFiles();
            $('#cancelButton').show();
            $('#doneButton').hide();
            // Refresh file list
            window.location.href="";
        });

        $('#doneButton').click(function(evt) {
            clearFiles();
            $('#cancelButton').show();
            $('#doneButton').hide();
            // Refresh file list
            window.location.href="";
        });

        $('#uploadButton').hide();
        $('#uploadProgress').hide();
        $('#abortButton').hide();
        $('#doneButton').hide();

    }

}

/*
// Upload function
*/

var requests = new Array();
var progress = new Array();
var failures = new Array();

function updatePrettyFileList(evt) {
    var files = evt.target.files;
    var output = [];
    if (files.length == 0){
        $('#uploadButton').hide();
        $('#uploadStatus').html('');
        $('#list tbody').html('');
        return;
    }

    for (var i = 0, f; f = files[i]; i++) {
        var row = $('<tr>');
        row.append('<td width="30%"><span class="glyphicon glyphicon-file"></span><strong>' + f.name + '</strong></td>');
        row.append('<td width="20%">' + f.size + '</td>');
        var p = $('<progress/>').hide();
        $('<td width="50%"/>').append(p).appendTo(row);
        progress.push(p);
        $('#list tbody').append(row);
    }

    $('#uploadButton').show();
    $('#uploadStatus').html('<div class="alert alert-warning" role="alert">' + i.toString() + ' Files ready for upload</div>');

}

function clearFiles() {
    console.debug('Called clearFiles');
    $('#uploadStatus').html('');
    $('#list table tbody').html('');
    $('#upload-form').each(function(){
        this.reset();
    });
    progress = new Array();
    $('#files').show();
}


function sendFile(file) {
    var n = requests.length;
    progress[n].show();
    var req = $.ajax({
        url: "/contribute/" + file.name,
        type: "POST",
        data: file,
        success: function(data, textStatus, jqXHR) {
        },
        error: function(jqXHR, textStatus, error) {
            progress[n].replaceWith('<span class="label label-danger">' + jqXHR.statusText + '</span>');
            failures.push(textStatus);
        },
        complete: function(jqXHR, textStatus) {
            requests.splice(requests.indexOf(jqXHR), 1);
            if (requests.length == 0){
                $('#abortButton').hide();
                $('#uploadStatus').prepend('');
                $('#cancelButton').hide();
                $('#doneButton').show();
                $('#upload-form').each(function(){
                    this.reset();
                });
                progress = new Array();
                $('#files').show();
                if (failures.length == 0){
                    $('#uploadStatus').html('<div class="alert alert-success" role="alert"><span class="glyphicon glyphicon-thumbs-up"></span>Upload completed</div>');
                } else {
                    $('#uploadStatus').html('<div class="alert alert-danger" role="alert"><span class="glyphicon glyphicon-thumbs-down"></span>' + failures.length + ' uploads failed</div>');

                }
            }
        },
        processData: false,
        xhr: function() {
            // Custom XMLHttpRequest for progress
            var myXHR = $.ajaxSettings.xhr();
            if (myXHR.upload) {
                myXHR.upload.addEventListener('progress', function(e){
                    if (e.lengthComputable){
                        progress[n].attr({
                            value: e.loaded,
                            max: e.total
                        });
                    }
                }, false);
            }
            return myXHR;
        }
    });
    requests.push(req);
}
