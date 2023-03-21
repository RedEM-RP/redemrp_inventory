var targetPlayerId = 0;
var SecondInventoryActive = false;
var SplittingObject = null;
var SplitMode = false;

$(function(){
	window.onload = (e) => {
		window.addEventListener('message', (event) => {
			switch (event.data.type){
				case 1:	{
					show(event.data.inventory, event.data.otherinventory, event.data.crafting);
					getItems(event.data.items, event.data.otheritems, event.data.target, event.data.weight);
                    $("#money").html(`$${event.data.money}`);
                    $("#clock").html(`${event.data.time}`);
					break;
				}
				case 2: {
					hide();
					break;
				}
				default: {
					hide();
				}
			}
		});
	};
});

$(function() {
	$.contextMenu({
		selector: '.item-content', 
		className: 'contextmenu-inventory',
		callback: function(key, options) {
			var objectId = options.$trigger.attr('objectId');
			var nodrop = false;
            var nouse = false;
            var nogive = false;
			var classname = $(options.$trigger).parent().parent().attr('class');
			//console.log(classname);
			if (classname.includes("box0")) {
				nodrop = true;
                nouse = true;
                nogive = true;
			}
			if(key == "use" && !nouse) {
				var object = getObjectById(objectId);
				$.post(`https://${GetParentResourceName()}/useitem`, JSON.stringify({
					data: object
				}));
			} else if(key == "split") {
                SplittingObject = objectId;
				ShowSplit(Math.floor(getObjectById(objectId).amount/2));
			} else if(key == "drop" && !nodrop) {
				var object = getObjectById(objectId);
				$.post(`https://${GetParentResourceName()}/dropitem`, JSON.stringify({
					data: object
				}));
			} else if(key == "give" && !nogive) {
				var object = getObjectById(objectId);
				$.post(`https://${GetParentResourceName()}/giveitem`, JSON.stringify({
					data: object
				}));
			}
            else if(key == "transfer") {
                //console.log(SecondInventoryActive)
                if (SecondInventoryActive) {
                    if (classname.includes("box0")) {
                        var object = getObjectById(objectId);
                        $.post(`https://${GetParentResourceName()}/additem`, JSON.stringify({
                            data: object,
                            target: targetPlayerId
                        }));
                    } else {
                        var object = getObjectById(objectId);
                        $.post(`https://${GetParentResourceName()}/removeitem`, JSON.stringify({
                            data: object,
                            target: targetPlayerId
                        }));
                    }
                }
            }
		},
		items: {
			"use": {name: "Use"},
			"split": {name: "Split"},
			"drop": {name: "Drop"},
			"give": {name: "Give"},
            "transfer": {name: "Transfer"},
		}
	});
});

function ShowSplit(amt) {
    SplitMode = true;
    $("#splitBox").show();
    $("#splitamt").val(amt);
    $(".inventory").css("pointer-events", "none");
    $(".inventory").css("opacity", "0.3");
    $(".grid").css("pointer-events", "none");
    $(".grid").css("opacity", "0.3");
    $("#splitamt").focus();
}

$("#splitConf").click(function() {
    if(SplittingObject) {
        var object = getObjectById(SplittingObject);

        if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;
        var amount = $("#splitamt").val();
        if(amount > 0 && amount < object.amount) {
            var val = Math.floor(object.amount - amount);
            setObjectAmount(SplittingObject, val, false);
            addObject({
                name: object.name,
                description: object.description,
                label: object.label,
                type: object.type,
                amount: amount,
                imgsrc: object.imgsrc,
                box: object.box,
                meta: object.meta
            });
        }
    } 
    SplitMode = false;
    $("#splitBox").hide();
    $(".inventory").css("pointer-events", "auto");
    $(".inventory").css("opacity", "1.0");
    $(".grid").css("pointer-events", "auto");
    $(".grid").css("opacity", "1.0");
});

$("#splitamt").keyup(function(e) {
    if(e.key == "Enter") {
        if(SplittingObject) {
            var object = getObjectById(SplittingObject);
    
            if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;
            var amount = $("#splitamt").val();
            if(amount > 0 && amount < object.amount) {
                var val = Math.floor(object.amount - amount);
                setObjectAmount(SplittingObject, val, false);
                addObject({
                    name: object.name,
                    description: object.description,
                    label: object.label,
                    type: object.type,
                    amount: amount,
                    imgsrc: object.imgsrc,
                    box: object.box,
                    meta: object.meta
                });
            }
        } 
        SplitMode = false;
        $("#splitBox").hide();
        $(".inventory").css("pointer-events", "auto");
        $(".inventory").css("opacity", "1.0");
        $(".grid").css("pointer-events", "auto");
        $(".grid").css("opacity", "1.0");
    } else if (e.key == "Escape") {
        $("#splitBox").hide();
        $(".inventory").css("pointer-events", "auto");
        $(".inventory").css("opacity", "1.0");
        $(".grid").css("pointer-events", "auto");
        $(".grid").css("opacity", "1.0");
        setTimeout(() => {
            SplitMode = false;
        }, 500);
    }
});

$("#splitCancel").click(function() {
    SplitMode = false;
    $("#splitBox").hide();
    $(".inventory").css("pointer-events", "auto");
    $(".inventory").css("opacity", "1.0");
    $(".grid").css("pointer-events", "auto");
    $(".grid").css("opacity", "1.0");
});


function createObjectBox(object) {

    const box = document.createElement("div");
    box.setAttribute('class', 'item');
    box.setAttribute('data-amount', object.amount);
    if (object.box > 3) {
        document.getElementsByClassName(`slot${object.box-3}`)[0].appendChild(box);
    } else {
        document.getElementsByClassName(`box${object.box}`)[0].appendChild(box);
    }

    const boxContent = document.createElement("div");
    box.appendChild(boxContent);
    boxContent.setAttribute('class', 'item-content');
    boxContent.setAttribute('objectId', object.id);
    //boxContent.setAttribute('oncontextmenu', `openContextMenu(${object.id})`);
    //boxContent.setAttribute('ondblclick', `cloneBox(${object.id})`);
    if (object.name == "letter") {
        if (object.meta.name == "") {
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `A letter addressed to nobody`)    ");
        } else {
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `A letter addressed to " + object.meta.name + "`)    ");
        }
    } else if(object.name == "newspaper") {
        boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `A newspaper (edition " + object.meta.edition + ")`)    ");
    } else if(object.name == "wateringcan") {
        if(object.meta.water != undefined && object.meta.water != null) {
            var waterdisp = object.meta.water * 10;
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `A watering can (" + waterdisp.toFixed(0) + "% Full)`)    ");
        }
    } else if(object.name == "canteen") {
        if(object.meta.water != undefined && object.meta.water != null) {
            var waterdisp = object.meta.water * 10;
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `A canteen (" + waterdisp.toFixed(0) + "% Full)`)    ");
        }
    } else if(object.type == "item_weapon") {
        if((object.meta.damage != undefined && object.meta.damage != null) &&
         (object.meta.dirt != undefined && object.meta.dirt != null)) {
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `" + object.description + " (" + (object.meta.dirt*100).toFixed(2) + "% Dirt, "+(object.meta.damage*100).toFixed(2)+"% Damage)`)    ");
        } else {
            boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `" + object.description + "`)    ");
        }
    } else {
        boxContent.setAttribute('onmouseover', "Over(`" + object.label + "`, `" + object.description + "`)    ");
    }
    

    /*
	$(boxContent).mousedown(function(event) {
		switch (event.which) {
            case 1: {
				if(event.shiftKey) {
                    console.log(JSON.stringify(object));
                    if (object.box == 0) {
                        var object = getObjectById(object.id);
                        $.post(`https://${GetParentResourceName()}/additem`, JSON.stringify({
                            data: object,
                            target: targetPlayerId
                        }));
                    } else {
                        var object = getObjectById(object.id);
                        $.post(`https://${GetParentResourceName()}/removeitem`, JSON.stringify({
                            data: object,
                            target: targetPlayerId
                        }));
                    }
				}
				break;
			}
			case 3: {
				if(event.shiftKey) {
					$(boxContent).contextMenu(false);
					cloneBox(object.id);
				} else {
					$(boxContent).contextMenu(true);
				}
				break;
			}
		}
	});*/
    $(boxContent).mousedown(function(event) {
		switch (event.which) {
			case 3: {
				if(event.shiftKey) {
                    //console.log(JSON.stringify(object));
					$(boxContent).contextMenu(false);
					cloneBox(object.id);
				} else {
					$(boxContent).contextMenu(true);
				}
				break;
			}
		}
	});
    const mainContent = document.createElement("div");
    mainContent.setAttribute('class', 'item-content-main');
    boxContent.appendChild(mainContent);

    const img = document.createElement("img");
    img.src = object.imgsrc;
    img.style.position = 'absolute';
    img.style.left = '50%';
    img.style.height = '90%';
    img.style.marginRight = '-50%';
    img.style.transform = 'translate(-50%, 0%)';
    mainContent.appendChild(img);

    const sliderBox = document.createElement("div");
    sliderBox.setAttribute('class', 'item-content-footer');
    sliderBox.style.display = 'none';
    boxContent.appendChild(sliderBox);

    const amountBox = document.createElement("div");
    boxContent.appendChild(amountBox);
    amountBox.setAttribute('class', 'item-content-footer');
    amountBox.innerHTML = object.amount;

    return box;
}



function cloneBox(id) {
    object = getObjectById(id);

    if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;

    neighbour = getObjectsByNameAndMeta(object.name, object.meta).find(obj => obj.box == object.box && obj.id != id);
    setObjectAmount(id, object.amount - 1, false);

    if (neighbour) setObjectAmount(neighbour.id, neighbour.amount + 1, false);
    else return addObject({
        name: object.name,
        description: object.description,
        label: object.label,
        type: object.type,
        amount: 1,
        imgsrc: object.imgsrc,
        box: object.box,
        meta: object.meta
    });
}


function openContextMenu(id) {
    object = getObjectById(id);
	new Contextual({
		items: menuItems
	});


    neighbour = getObjectsByNameAndMeta(object.name, object.meta).find(obj => obj.box == object.box && obj.id != id);
    setObjectAmount(id, object.amount - 1, false);

    if (neighbour) setObjectAmount(neighbour.id, neighbour.amount + 1, false);
    else return addObject({
        name: object.name,
        description: object.description,
        label: object.label,
        type: object.type,
        amount: 1,
        imgsrc: object.imgsrc,
        box: object.box,
        meta: object.meta
    });
}



function cloneBox2(id) {
    object = getObjectById(id);

    if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;
    var val = Math.floor(object.amount / 2);
    setObjectAmount(id, object.amount - val, false);
    addObject({
        name: object.name,
        description: object.description,
        label: object.label,
        type: object.type,
        amount: val,
        imgsrc: object.imgsrc,
        box: object.box,
        meta: object.meta
    });
}

function cloneBox2Amt(id, amt) {
    object = getObjectById(id);

    if (object.amount <= 1 || object.box > 3 || object.type == "item_weapon") return;
    var val = Math.floor(object.amount - amt);
    setObjectAmount(id, object.amount - val, false);
    addObject({
        name: object.name,
        description: object.description,
        label: object.label,
        type: object.type,
        amount: val,
        imgsrc: object.imgsrc,
        box: object.box,
        meta: object.meta
    });
}


function addObject(data) {
    id = objects.length ? objects[objects.length - 1].id + 1 : 1;
    obj = {
        id: id,
        name: data.name,
        description: data.description,
        label: data.label,
        type: data.type,
        meta: data.meta,
        amount: data.amount,
        imgsrc: data.imgsrc,
        box: data.box,
    };
    objects.push(obj);
    grids[parseInt(data.box)].add(createObjectBox(obj))[0]._id = id;
    return obj;
}

function getObjectById(id) {
    return objects.find(obj => obj.id == id);
}

function getObjectsByNameAndMeta(name, meta) {
    return objects.filter(obj => obj.name == name && obj.meta == meta);
}

function getAmountSum(name, meta) {
    return getObjectsByNameAndMeta(name, meta).reduce((sum, {
        amount
    }) => sum + amount, 0);
}

function getObjectHTML(objectId) {
    return document.querySelector(`[objectId='${objectId}']`);
}

function setObjectAmount(id, amount, affectOnOthers = true) {
    if (amount <= 0) {
        removeObjects([getObjectById(id)]);
        return;
    }
    object = getObjectById(id);
    difference = parseInt(amount) - object.amount;

    object.amount = parseInt(amount);
    boxContent = getObjectHTML(id);
    boxContent.lastChild.innerHTML = amount;
    if (difference == 0 || !affectOnOthers) return;
    if (getObjectsByNameAndMeta(object.name, object.meta).length == 1) {
        addObject({
            name: object.name,
            description: object.description,
            label: object.label,
            type: object.type,
            meta: object.meta,
            amount: -difference,
            imgsrc: object.imgsrc,
            box: object.box
        });
        return;
    }

    for (const destinationBox of objectsMoveDirections[object.box]) {
        destinationObjects = getObjectsByNameAndMeta(object.name, object.meta).filter(obj => obj.box == destinationBox && obj.id != id);

        for (const destinationobject of destinationObjects) {
            if (destinationobject.amount >= difference) {
                setObjectAmount(destinationobject.id, destinationobject.amount - difference, false);
                return;
            } else {
                difference -= destinationobject.amount;
                setObjectAmount(destinationobject.id, 0, false);
            }
        }
    }
}

function getObjectsFromBox(box_nr) {
    return objects.filter(({
        box
    }) => box == box_nr);
}

function onDragFinished(data) {

    // get dragged object
    draggedObject = getObjectById(data.item._id);
    // get all repeated elements

    repeats = getObjectsFromBox(data.toGrid._id - 1).filter(({
        name,
        meta
    }) => name == draggedObject.name && deepEqual(meta, draggedObject.meta));
    if (draggedObject.type == "item_standard") {
        // add amount of objects from this box
        repeatsAmount = repeats.reduce( (sum, {amount} ) => parseInt(sum) + parseInt(amount), 0 );
        setObjectAmount(data.item._id, parseInt(draggedObject.amount) + parseInt(repeatsAmount), false);
    }
    // set new box value to object
    getObjectById(data.item._id).box = data.toGrid._id - 1;
    // remove all repeats

    removeObjects(repeats);
}

function deepEqual(object1, object2) {
    const keys1 = Object.keys(object1);
    const keys2 = Object.keys(object2);

    if (keys1.length !== keys2.length) {
        return false;
    }

    for (const key of keys1) {
        const val1 = object1[key];
        const val2 = object2[key];
        const areObjects = isObject(val1) && isObject(val2);
        if (
            areObjects && !deepEqual(val1, val2) ||
            !areObjects && val1 !== val2
        ) {
            return false;
        }
    }

    return true;
}

function isObject(object) {
    return object != null && typeof object === 'object';
}


function removeObjects(arrayOfObjects) {
    arrayOfObjects.forEach(obj => {
        //Remove from grid
        grids[parseInt(obj.box)].remove(grids[parseInt(obj.box)].getItems().find(({
            _id
        }) => _id == obj.id));
        //Delete HTML element
        box = getObjectHTML(obj.id).parentElement;
        box.parentElement.removeChild(box);
        //Remove from objects array
        objects = objects.filter(obj => !arrayOfObjects.find(el => el.id == obj.id))
    })
}

const objectsMoveDirections = [
    [0, 1, 2],
    [1, 0, 2],
    [2, 1, 0]
];

let objects = [];
hide();
let objectsIn = null;
var secondInventoryId = -1

var grids = [
    new Muuri('.box0', {
        dragEnabled: true,
        dragContainer: document.body,
        dragSort: () => grids,
        sortData: {
            amount: function(item, element) {
                return parseFloat(element.getAttribute('data-amount'));
            }
        },
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data))
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '16%';
        item.getElement().style.height = '6vh';
        grids.forEach(function(grid) {
            grid.refreshItems();
        });
    }),


    new Muuri('.box1', {
        dragEnabled: true,
        dragContainer: document.body,
        dragSort: () => grids,
        sortData: {
            amount: function(item, element) {
                return parseFloat(element.getAttribute('data-amount'));
            }
        },
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', function(data) {
        if (data.toGrid._id == 1) {
            var object = getObjectById(data.item._id);
            $.post(`https://${GetParentResourceName()}/removeitem`, JSON.stringify({
                data: object,
                target: targetPlayerId
            }));
        }
        onDragFinished(data)
    })
    .on('beforeReceive', function(data) {
        if (data.fromGrid._id == 1) {
            var object = getObjectById(data.item._id);
            $.post(`https://${GetParentResourceName()}/additem`, JSON.stringify({
                data: object,
                target: targetPlayerId
            }));
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '16%';
        item.getElement().style.height = '6vh';
        grids.forEach(function(grid) {
            grid.refreshItems();
        });
    }),

	/*
    new Muuri('.box2', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {

            handle: '.item-content-main, .item-content-amount-moved'
        }
    })
    .on('receive', function(data) {
        if (data.fromGrid._id == 2) {
            var object = getObjectById(data.item._id);

            $.post(`https://${GetParentResourceName()}/dropitem`, JSON.stringify({
                data: object
            }), );
        } else {
            ItemBack(data);
        }
    })
    .on('send', data => onDragFinished(data))
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '15.2%';
        item.getElement().style.height = '8vh';
        grids.forEach(function(grid) {
            grid.refreshItems();
        });
    }),

	
    new Muuri('.box3', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {

            handle: '.item-content-main, .item-content-amount-moved'
        }
    })
    .on('receive', function(data) {

        if (data.fromGrid._id == 2) {
            var object = getObjectById(data.item._id);
            $.post(`https://${GetParentResourceName()}/useitem`, JSON.stringify({
                data: object
            }), );
            ItemBack(data);
        } else {
            ItemBack(data);
        }
    })
    .on('send', data => onDragFinished(data))
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '15.2%';
        item.getElement().style.height = '8vh';
        grids.forEach(function(grid) {
            grid.refreshItems();
        });
    }),*/

    new Muuri('.slot1', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data))
    .on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';
    }),

    new Muuri('.slot2', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),


    new Muuri('.slot3', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot4', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot5', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot6', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot7', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot8', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })
    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';

    }),

    new Muuri('.slot9', {
        dragEnabled: true,
        dragSort: () => grids,
        dragContainer: document.body,
        dragStartPredicate: {
            handle: '.item-content-main, .item-content-amount-moved'
        }
    }).on('send', data => onDragFinished(data)).on('receive', function(data) {
        if (GetNumberOfItems(data) > 1 || (data.fromGrid._id < 4 && data.fromGrid._id != 2)) {
            ItemBack(data);
        }
    })
    .on('dragStart', function(item) {
        item.getElement().style.width = item.getWidth() + 'px';
        item.getElement().style.height = item.getHeight() + 'px';
    })

    .on('dragReleaseEnd', function(item) {
        item.getElement().style.width = '85%';
        item.getElement().style.height = '85%';
    }),
];

function hide() {
    SplitMode = false;
    $("body").css("display", "none");
    $("#splitBox").hide();
    $(".inventory").css("pointer-events", "auto");
    $(".inventory").css("opacity", "1.0");
    $(".grid").css("pointer-events", "auto");
    $(".grid").css("opacity", "1.0");
}

function GetNumberOfItems(data) {
    return grids[data.toGrid._id - 1]._items.length;
}

$("#craftButton").click(function() {
    const message = [];

    for (i = 2; i <= 10; i++) {
        message.push(GetCraftingSlotData(i));
    }

    $.post(`https://${GetParentResourceName()}/craft`, JSON.stringify(message));
});

function GetCraftingSlotData(id) {
    var name = "empty";
    var amount = 0;
    var meta = [];

    if (grids[id]._items[0] != null) {
        var itemId = grids[id]._items[0]._id
        var object = getObjectById(itemId);
        name = object.name;
        amount = object.amount;
        meta = object.meta;
    }

    return [name, amount, meta]

}

function ItemBack(data) {
    var object = getObjectById(data.item._id);
    if (data.fromGrid._id > 4) {
        addObject({
            name: object.name,
            meta: object.meta,
            label: object.label,
            type: object.type,
            amount: object.amount,
            imgsrc: object.imgsrc,
            box: 1,
        });
    } else {
        addObject({
            name: object.name,
            meta: object.meta,
            label: object.label,
            type: object.type,
            amount: object.amount,
            imgsrc: object.imgsrc,
            box: data.fromGrid._id - 1
        });
    }
    removeObjects([object]);
    grids[0].sort('amount:desc', {
        layout: 'instant'
    });
    grids[1].sort('amount:desc', {
        layout: 'instant'
    });
}

function show(playerInventory, otherInventory, crafting) {
    $("body").css("display", 'block');

    if(otherInventory){
        //console.log("Other inventory")
        $("#selfinv").css("height", "40.5%");
        SecondInventoryActive = true;
    } else {
        //console.log("NO Other inventory")
        $("#selfinv").css("height", "80.5%");
        SecondInventoryActive = false;
    }

    $(".box0").css("display", (otherInventory) ? 'block' : 'none');
	$(".box1").css("display", (playerInventory) ? 'block' : 'none');
    $(".grid").css("display", (crafting) ? 'block' : 'none');
    $('.invCraft').css("display", (crafting) ? 'block' : 'none');
	$(".grid").css("display", 'block');
    $(".invCraft").css("display", 'block');
}

var shiftactive = false;
$(document).keydown(function(e) {
    if (e.keyCode == 16) {
        shiftactive = true;
    }
});

grids[1].on('dragMove', function(item, event) {
    var i;
    if (shiftactive) {
        for (i = 0; i < objects.length; i++) {

            if (parseInt(item._id) !== parseInt(objects[i].id)) {
                if (getObjectHTML(item._id) != null) {
                    var coords = getObjectHTML(item._id).getBoundingClientRect();
                    var coords2 = getObjectHTML(objects[i].id).getBoundingClientRect();
                    var a = coords.top - coords2.top;
                    var b = coords.left - coords2.left;
                    var c = Math.sqrt(a * a + b * b);

                    if (c < 40) {
                        var object = getObjectById(objects[i].id);
                        var object2 = getObjectById(item._id);
                        if (object2.name == object.name && deepEqual(object2.meta, object.meta)) {

                            boxContent = getObjectHTML(item._id);
                            boxContent.lastChild.innerHTML = parseInt(object2.amount + object.amount);
                            object2.amount = parseInt(object2.amount + object.amount);
                            removeObjects([object]);
                        }
                    }
                }
            }
            shiftactive = false;
        }
    }
});



function Over(item, desc) {
    var name = document.getElementById("info2");
    var opis = document.getElementById("info3");
    if (item == null) {
        name.innerHTML = "";
        opis.innerHTML = "";
    } else {
        name.innerHTML = item;
        opis.innerHTML = desc;
    }
}



async function getItems(data, secondInventory, targetPlayer, weight) {
    objectsIn = data;
    targetPlayerId = targetPlayer;
    removeObjects(objects);
    for (x in data) {
        data[x].box = 1;
        addObject(data[x]);
    }
    if (secondInventory) {
        for (x in secondInventory) {
            secondInventory[x].box = 0;
            addObject(secondInventory[x]);
        }
    } 
    var weight_object = document.getElementById("weight");
    weight_object.innerHTML = Math.round(weight * 100) / 100 + " / 45 KG";
    grids[0].sort('amount:desc', {
        layout: 'instant'
    });
    grids[1].sort('amount:desc', {
        layout: 'instant'
    });
}



$(document).keyup(function(e) {
    if ((e.keyCode == 27 || e.keyCode == 66) && !SplitMode) { //hide eq
        console.log("SplitMode = " + SplitMode);
        hide();
        $.post(`https://${GetParentResourceName()}/close`);
    }
});
