// create an html file for any svg you would like to use
// import it here to make it available for use
// remember to replace the Lorem text with the {message} prop
// link to confluence article : https://confluentinc.atlassian.net/wiki/spaces/BizSys/pages/1244402509/UI+Placeholders+Filling+Blank+Space+LWCs

import { LightningElement, api } from 'lwc';

// svg imports
import svgShowEmpty from './svgShowEmpty.html';
import svgGoneFishing from './svgGoneFishing.html';
import svgDesert from './svgDesert.html';
import svgOpenRoad from './svgOpenRoad.html';
import svgCamping from './svgCamping.html';
import svgFishingDeals from './svgFishingDeals.html';
import svgPageNotAvailable from './svgPageNotAvailable.html';

export default class Placeholder extends LightningElement {

    @api svgname;
    @api message;

    // mapping from input param to template
    renderHtml = {
        'showEmpty': svgShowEmpty,
        'goneFishing': svgGoneFishing,
        'noDataFound': svgDesert,
        'noDataFoundAlternate': svgOpenRoad,
        'maintenance': svgCamping,
        'fishingDeals': svgFishingDeals,
        'pageNotAvailable': svgPageNotAvailable,
    };

    render() {

        if (this.renderHtml[this.svgname]) {

             return this.renderHtml[this.svgname];
        }
        else {

            return svgShowEmpty;
        }
    }
}