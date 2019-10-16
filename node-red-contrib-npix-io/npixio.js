module.exports = function(RED) {
    "use strict";
    var fs = require('fs');
    var gpio = require('rpi-gpio');
    var events = require('events');
    var outnodesemit = [];
    var outfirstinit = false;
    var outnodes = 0;
    var nodes = 0;


    // NPIX-IO output node
    function npixiooutputNode(n) {
      RED.nodes.createNode(this, n);

      if( outfirstinit === false) {
          // wait for GPIO 27 (HAT pin 13) (overload/heat) to change its state

          gpio.on('change', function(channel, value) {
              // check the status pin
              if( channel === 13 ) {
                 for (var idx = 0; idx < outnodesemit.length; idx++) {
                    if( value === false ) {
                       outnodesemit[idx].myEmitter.emit('error');
                    } else {
                       outnodesemit[idx].myEmitter.emit('ok');
                    }
                 }
              }
          });

          // setup GPIO 27 (HAT pin 13) to input to get module overload/heat status
          gpio.setup(13, gpio.DIR_IN, gpio.EDGE_BOTH, function (err) {
             gpio.read(13, function (err,value) {
                if(err) {
                   RED.log.warn("[npixiooutput] Unable to read overload/heat status");
                } else {
                   for (var idx = 0; idx < outnodesemit.length; idx++) {
                      if( value === false ) {
                         outnodesemit[idx].myEmitter.emit('error');
                      } else {
                         outnodesemit[idx].myEmitter.emit('ok');
                      }
                   }
                }
            });
          });
          outfirstinit = true;
      }


      this.out = n.out;
      var node = this;

      node.myEmitter = new events.EventEmitter;
      node.myEmitter.on('ok', function () {
        node.status({fill:"green",shape:"dot",text:"ok"});
      });
      node.myEmitter.on('error', function () {
       node.status({fill:"red",shape:"dot",text:"overload/heat"});
      });
      outnodesemit.push(node);

      gpio.setup(parseInt(node.out), gpio.DIR_HIGH, function (err) {
          if (err) {
              RED.log.warn("[npixiooutput] Can't control output, maybe already in use");
          } else {
              nodes++;
              outnodes++;
              node.on("input", function(msg) {
                  var out = node.out;
                  if( msg.payload === 0) {
                      gpio.write(parseInt(out), false);
                  } else {
                      gpio.write(parseInt(out), true);
                  }
              });
              node.on("close", function(done) {
                  outnodes--;
                  if( outnodes === 0 ) {
                      outnodesemit = [];
                      outfirstinit = false;
                  }

                  nodes--;

                  if( nodes === 0) {
                      gpio.destroy( function() {
                        done();
                      });
                  } else {
                    done();
                  }
              });
          }
      });
    }
    RED.nodes.registerType("npixiooutput", npixiooutputNode);

    // NPIX-IO input node
    function npixioinputNode(n) {
      RED.nodes.createNode(this, n);
      this.in = n.in;
      var node = this;

      

      gpio.setup(parseInt(node.in), gpio.DIR_IN, gpio.EDGE_BOTH, function (err) {
          if(err) {
                RED.log.warn("[npixioinput] Can't control input, maybe already in use");
          } else {
            gpio.on('change', function(channel, value) {
                // check the input pin
                if( channel === parseInt(node.in) ) {
                    var tempMsg = {};
                    if (node.in === "7") {
                        tempMsg.topic = "in0";
                    } else if (node.in === "8") {
                        tempMsg.topic = "in1";
                    } else if (node.in === "10") {
                        tempMsg.topic = "in2";
                    } else {
                        tempMsg.topic = "in3";
                    }
                    if( value === true ) {
                        tempMsg.payload = 1;
                        node.status({fill:"green",shape:"dot",text:"set"});
                    } else {
                        tempMsg.payload = 0;
                        node.status({fill:"green",shape:"ring",text:"cleared"});
                    }
                    node.send(tempMsg);
                }
            });  
              
            gpio.read(parseInt(node.in), function (err,value) {
                if(err) {
                    RED.log.warn("[npixioinput] Unable to read module input value");
                } else {

                    nodes++;
                    node.on("close", function(done) {
                      nodes--;

                      if( nodes === 0) {
                          gpio.destroy( function() {
                             done();
                          });
                      } else {
                        done();
                     }

                    });

                    var tempMsg = {};
                    if (node.in === "7") {
                        tempMsg.topic = "in0";
                    } else if (node.in === "8") {
                        tempMsg.topic = "in1";
                    } else if (node.in === "10") {
                        tempMsg.topic = "in2";
                    } else {
                        tempMsg.topic = "in3";
                    }
                    if( value === true ) {
                        tempMsg.payload = 1;
                        node.status({fill:"green",shape:"dot",text:"set"});
                    } else {
                        tempMsg.payload = 0;
                        node.status({fill:"green",shape:"ring",text:"cleared"});
                    }
                    node.send(tempMsg);
                }
            });
          }
      });
    }
    RED.nodes.registerType("npixioinput", npixioinputNode);
}
                          
              
